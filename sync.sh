#!/usr/bin/env bash
# Paste CONVENTIONS.md into a project's root AGENTS.md, between the markers
# "<!-- conventions ... -->" and "<!-- /conventions -->", with its headings
# demoted one level. The first time, the block goes before the project's
# first "## " heading; afterwards it replaces itself. Copy each skill in
# skills/ into the project's .agents/skills/, its SKILL.md marked with the
# commit it came from, linked from .claude/skills/; a skill once copied and
# since removed here is removed there.
#
#   ./sync.sh <checkout>...          update AGENTS.md in each checkout
#   ./sync.sh --check <checkout>...  change nothing; exit 1 if any is behind
#
# AGENTS.md must be a regular file and CLAUDE.md beside it a symlink to it;
# a checkout still laid out the other way round is refused.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
src="$repo_dir/CONVENTIONS.md"
end_marker='<!-- /conventions -->'

check=false
checkouts=()
for arg in "$@"; do
  case "$arg" in
    --check) check=true ;;
    -*) printf 'unknown option: %s\n' "$arg" >&2; exit 2 ;;
    *) checkouts+=("$arg") ;;
  esac
done
if [[ ${#checkouts[@]} -eq 0 ]]; then
  sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 2
fi

if ! git -C "$repo_dir" diff --quiet -- CONVENTIONS.md; then
  printf 'CONVENTIONS.md has uncommitted changes: commit them first, the block names its commit\n' >&2
  exit 2
fi
if [[ -n "$(git -C "$repo_dir" status --porcelain -- skills)" ]]; then
  printf 'skills/ has uncommitted changes: commit them first, each copy names its commit\n' >&2
  exit 2
fi
rev="$(git -C "$repo_dir" log -1 --format=%h -- CONVENTIONS.md)"
skill_marker='<!-- conventions: dahu33/conventions@'

block="$(mktemp)"
staged="$(mktemp -d)"
trap 'rm -rf "$block" "$staged"' EXIT
{
  printf '<!-- conventions: dahu33/conventions@%s, pasted by sync.sh; change it there, not here -->\n' "$rev"
  sed 's/^#/##/' "$src"
  printf '%s\n' "$end_marker"
} > "$block"

# Each skill as a project gets it: its files, and a marker after the frontmatter of its SKILL.md.
skills=()
for dir in "$repo_dir"/skills/*/; do
  [[ -f "$dir/SKILL.md" ]] || continue
  name="$(basename "$dir")"
  skills+=("$name")
  cp -R "${dir%/}" "$staged/$name"
  skill_rev="$(git -C "$repo_dir" log -1 --format=%h -- "skills/$name")"
  awk -v marker="$skill_marker$skill_rev, copied by sync.sh; change it there, not here -->" '
    { print }
    $0 == "---" && ++fences == 2 { print ""; print marker }
  ' "$dir/SKILL.md" > "$staged/$name/SKILL.md"
done

# Prints the changes the project's skills need, one per line, or nothing when they are current.
skill_changes() { # $1=checkout
  local name dir
  for name in ${skills[@]+"${skills[@]}"}; do
    if ! diff -rq "$staged/$name" "$1/.agents/skills/$name" > /dev/null 2>&1; then printf 'copy %s\n' "$name"; fi
    if [[ "$(readlink "$1/.claude/skills/$name")" != "../../.agents/skills/$name" ]]; then printf 'link %s\n' "$name"; fi
  done
  for dir in "$1"/.agents/skills/*/; do
    name="$(basename "$dir")"
    [[ -f "$dir/SKILL.md" && ! -d "$staged/$name" ]] || continue
    if grep -q "^$skill_marker" "$dir/SKILL.md"; then printf 'remove %s\n' "$name"; fi
  done
}

behind=0
for checkout in "${checkouts[@]}"; do
  file="$checkout/AGENTS.md"
  link="$checkout/CLAUDE.md"
  if [[ -L "$file" || ! -f "$file" ]]; then
    printf '%s: AGENTS.md must be a regular file (git rm AGENTS.md && git mv CLAUDE.md AGENTS.md && ln -s AGENTS.md CLAUDE.md)\n' "$checkout" >&2
    exit 2
  fi
  if [[ ! -L "$link" || "$(readlink "$link")" != "AGENTS.md" ]]; then
    printf '%s: CLAUDE.md must be a symlink to AGENTS.md (ln -s AGENTS.md CLAUDE.md)\n' "$checkout" >&2
    exit 2
  fi
  has_markers=0
  grep -q '^<!-- conventions' "$file" && has_markers=1

  updated="$(mktemp)"
  awk -v blockfile="$block" -v has_markers="$has_markers" -v end_marker="$end_marker" '
    BEGIN { while ((getline line < blockfile) > 0) block = block line "\n" }
    !done && /^<!-- conventions/ { printf "%s", block; skipping = 1; next }
    skipping { if ($0 == end_marker) { skipping = 0; done = 1 }; next }
    !done && !has_markers && /^## / { printf "%s\n", block; done = 1 }
    { print }
    END { if (!done) printf "\n%s", block }
  ' "$file" > "$updated"

  changes="$(skill_changes "$checkout")"
  if cmp -s "$file" "$updated" && [[ -z "$changes" ]]; then
    printf 'current  %s\n' "$checkout"
  elif $check; then
    printf 'BEHIND   %s\n' "$checkout"
    behind=1
  else
    cp "$updated" "$file"
    while read -r action name; do
      case "$action" in
        copy) mkdir -p "$checkout/.agents/skills"; rm -rf "$checkout/.agents/skills/$name"; cp -R "$staged/$name" "$checkout/.agents/skills/$name" ;;
        link) mkdir -p "$checkout/.claude/skills"; rm -f "$checkout/.claude/skills/$name"; ln -s "../../.agents/skills/$name" "$checkout/.claude/skills/$name" ;;
        remove) rm -rf "$checkout/.agents/skills/$name"; rm -f "$checkout/.claude/skills/$name" ;;
      esac
    done <<< "$changes"
    printf 'updated  %s\n' "$checkout"
  fi
  rm -f "$updated"
done

exit $behind
