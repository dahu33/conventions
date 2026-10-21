# conventions

This repository holds [CONVENTIONS.md](CONVENTIONS.md), the rules every one of Pierre's projects shares, and `sync.sh`, which pastes it into a project's `AGENTS.md`. [README.md](README.md) says how.

- `CONVENTIONS.md` applies here too: `AGENTS.md` is the instruction file and `CLAUDE.md` its symlink; one branch and one pull request per change, started from `origin/main`, squash-merged.
- A convention is Pierre's statement, generalized: no project names, no fixture or implementation detail, no history. Each lives in one section. The file links to nothing, since it is pasted into other repositories.
- A change here is not done until it is synced into every project listed in `README.md`, each as its own pull request.
- Verification: `git diff --check`; every relative link in the files touched resolves; `./sync.sh --check` against a checkout that was just synced exits 0.
