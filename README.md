# conventions

The rules every one of my projects shares, in one file: [CONVENTIONS.md](CONVENTIONS.md). The instruction files themselves, spend, alignment, the pull request workflow, local verification, rounds and reports, tests and design checks, test devices, forward-only migrations (over-the-air updates included), separable environments, specs, docs, issues, toolchain, agent skills, search noise, secrets.

A project's own `AGENTS.md` holds only what is specific to that project. The sibling [skills](https://github.com/dahu33/skills) repository holds my personal agent skills; this one holds the conventions.

## How a project carries the conventions

`AGENTS.md` is the instruction file in every directory that has one, and `CLAUDE.md` beside it is a symlink to it (`ln -s AGENTS.md CLAUDE.md`), so Codex and Claude Code read the same text once. `sync.sh` pastes `CONVENTIONS.md` into a project's root `AGENTS.md` between two marker comments, headings demoted one level, with a header naming the commit it came from:

```markdown
<!-- conventions: dahu33/conventions@abc1234, pasted by sync.sh; change it there, not here -->
## Conventions for every project
…
<!-- /conventions -->
```

The block goes before the project's first `##` section the first time, and replaces itself afterwards. Both tools read the file in every worktree on every machine with no install step, which is why it is a committed copy and not a submodule, a subtree or a machine-wide link. `sync.sh` refuses a checkout whose `AGENTS.md` is still a symlink or whose `CLAUDE.md` is a regular file: convert it first (`git rm AGENTS.md && git mv CLAUDE.md AGENTS.md && ln -s AGENTS.md CLAUDE.md`).

The skills every project shares live in [skills/](skills), one folder each. `sync.sh` copies each into the project's `.agents/skills/`, with a line after the frontmatter of its `SKILL.md` naming the commit it came from, and links it from `.claude/skills/`; a skill removed here is removed from a project at its next sync. They have no entry in the project's `skills-lock.json`. Each is called by name only (`disable-model-invocation: true` for Claude Code, `allow_implicit_invocation: false` in `agents/openai.yaml` for Codex), so it loads when a person or the project's own skill asks for it.

| Skill | What it does |
| --- | --- |
| [release-notes](skills/release-notes/SKILL.md) | Drafts a version's release notes for the app's users from what merged since the previous version |

```bash
./sync.sh ~/git/perso/montopo ~/git/perso/osara   # update each checkout's AGENTS.md and shared skills
./sync.sh --check ~/git/perso/montopo             # exit 1 and say so if it is behind
```

## Change a convention

1. Change `CONVENTIONS.md` here on its own branch and squash-merge the pull request.
2. For each project that carries it: a branch from `origin/main`, `sync.sh` on that checkout, one pull request, squash-merged.

The projects that carry it:

- [montopo](https://github.com/dahu33/montopo): an outdoor map app, offline topographic maps and GPS tracks, on Expo and Cloudflare.
- [osara](https://github.com/dahu33/osara): a household-cooking app with an AI assistant, on Expo and Cloudflare.
- [dowise](https://github.com/dahu33/dowise): a Splitwise-style app for shared expenses, on Expo and Cloudflare.
