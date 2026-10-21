# conventions

The rules every one of my projects shares, in one file: [CONVENTIONS.md](CONVENTIONS.md). The instruction files themselves, spend, alignment, the pull request workflow, local verification, forward-only migrations, specs, docs, toolchain, agent skills, secrets.

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

```bash
./sync.sh ~/git/perso/mapped ~/git/perso/osara   # update each checkout's AGENTS.md
./sync.sh --check ~/git/perso/mapped             # exit 1 and say so if it is behind
```

## Change a convention

1. Change `CONVENTIONS.md` here on its own branch and squash-merge the pull request.
2. For each project that carries it: a branch from `origin/main`, `sync.sh` on that checkout, one pull request, squash-merged.

The projects that carry it: [mapped](https://github.com/dahu33/mapped), [osara](https://github.com/dahu33/osara).
