#!/usr/bin/env bash
# Paste CONVENTIONS.md into a project's root AGENTS.md, between the markers
# "<!-- conventions ... -->" and "<!-- /conventions -->", with its headings
# demoted one level. The first time, the block goes before the project's
# first "## " heading; afterwards it replaces itself.
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
rev="$(git -C "$repo_dir" log -1 --format=%h -- CONVENTIONS.md)"

block="$(mktemp)"
trap 'rm -f "$block"' EXIT
{
  printf '<!-- conventions: dahu33/conventions@%s, pasted by sync.sh; change it there, not here -->\n' "$rev"
  sed 's/^#/##/' "$src"
  printf '%s\n' "$end_marker"
} > "$block"

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

  if cmp -s "$file" "$updated"; then
    printf 'current  %s\n' "$checkout"
  elif $check; then
    printf 'BEHIND   %s\n' "$checkout"
    behind=1
  else
    cp "$updated" "$file"
    printf 'updated  %s\n' "$checkout"
  fi
  rm -f "$updated"
done

exit $behind
