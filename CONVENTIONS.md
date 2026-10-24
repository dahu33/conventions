# Conventions for every project

Pierre's standing rules for all his repositories, copied into each project's `AGENTS.md` by this repository's `sync.sh`. The rest of a project's `AGENTS.md` adds what is specific to that project and never contradicts these. Where a rule says "the specs" or "the plan", it means the project's `specs/` and `plans/`.

## Agent instruction files

- `AGENTS.md` is the single source of truth for agent instructions.
- Always create and edit `AGENTS.md` directly, never `CLAUDE.md`.
- Whenever creating an `AGENTS.md` file, including in nested directories, also create a `CLAUDE.md` symlink pointing to it in the same directory (`ln -s AGENTS.md CLAUDE.md`).
- Never create standalone `CLAUDE.md` files or duplicate instruction content.
- If `CLAUDE.md` already exists, verify that it is the correct symlink. Never overwrite an existing regular file without reconciling its contents first.

## Spend

Nothing that costs money without an explicit request from Pierre: no paid plan, developer program, store account, mail service, build minutes, library licence or any other paid service. Free tiers are fine where the project's specs allow them. Nothing is deployed and nobody logs in to a provider until Pierre asks.

## Align before writing

The specs record Pierre's explicit statements, what he approved, and assumptions marked as such. Anything else a session fills in goes to Pierre as a proposal, or into the owning spec marked as assumed and into the report, where the project allows that. Ask Pierre only about ambiguities or conflicts the specs don't resolve. An absent or open requirement is not permission to invent one: make the simplest reversible choice, report it, and Pierre decides. Agreeing with a design, a spec or a plan is not saying to build: a milestone starts on Pierre's explicit confirmation.

## One pull request per milestone

Each milestone is its own branch, started from `origin/main` after a fetch (never from a local `main`, which may be stale), pushed, and merged into `main` on GitHub as its own pull request as soon as it is reviewed and verified; milestones are never batched. A branch is brought up to date once, right before it merges, by merging `origin/main` into it (never a rebase, never a force push). If the merge brought nothing, merge. If it did, rerun the typecheck and the lint; rerun a test suite only when the merge touched the same workspace as the branch or needed a conflict resolved. Merge with a squash (`gh pr merge --squash`, the only method the repository allows; head branches are deleted on merge): `main` holds one verified commit per milestone, titled like the pull request. The plan's status row is edited only in that final update, by whoever merges, so in-flight branches don't conflict on it.

## Verification is local and complete

Nothing runs on push or pull request: GitHub's build minutes are not spent, and a CI workflow, where one exists, runs on manual dispatch only and is neither verified nor maintained until Pierre brings CI back. Each project's `AGENTS.md` names its full verification, the checks to run while building, and the paths that count as specs and docs.

- **While building**, whoever implements (a build round, a fix round) runs the checks for what they touched, as the project's `AGENTS.md` defines it; they don't replace the full verification before merge. A change to dependencies or lockfiles, toolchain pins, shared, build or test-runner configuration, or shared test setup touches everything: it gets the full verification.
- **Before merge**, one full verification covers the final tree, normally run by whoever merges, right after bringing the branch up to date; an earlier full run counts only while it is still valid.
- **A result belongs to the commit it ran on.** It stays valid across two changes only: bringing the branch up to date, with the reruns "One pull request per milestone" asks for when the update brought commits, and later commits confined to the specs and docs paths, checked as below. Any other edit makes it stale, and nobody reports green from a stale result.
- **The pull request body** records the final gate: for each run, the commit, the exact commands and each result. Reviewers compare the recorded commit with the head and run only the targeted checks their own doubts call for, never the full suite as ritual.
- **Specs and docs only:** a pull request whose whole diff against its base stays within the project's specs and docs paths needs no full run. It, like a commit within those paths after a full run, gets `git diff --check` over the branch's whole diff, committed and uncommitted, and every relative link and anchor in the files touched resolves; a command it adds or changes runs once, or a cheap probe of it, and the report says which.

Every report says what it ran and what it did not. What needs a real device (GPS, background work, sensors, battery, airplane mode) is Pierre's to check: the report lists it.

## Data always moves forward

Every change to the shape of stored data (a table, a stored JSON document, a setting's value, any stored object) ships as a numbered, forward-only migration that rewrites existing data to the new shape, and product code knows one shape only. No compatibility branch, no read-time converter, no optional field standing in for a migration. A committed migration is never edited. What is a cache of something stored elsewhere is rebuilt or re-fetched, not migrated. Every brief that changes a stored shape names the migration; the builder's tests load a fixture of the previous shape and check it migrates. Names follow the project's naming rules; a new name that fits no row there is a question for Pierre.

## Specs

- Each requirement lives in exactly one file; other files link to it. Every spec separates confirmed behaviour, what is assumed or under exploration, and open questions.
- When Pierre states or changes a requirement, the owning spec is updated in the same task: replace contradicting wording, update the specs that depend on it, keep what the change didn't touch. When he answers an assumption, it becomes confirmed.
- Feedback on presentation changes the design direction. It doesn't imply new functional requirements.
- Never turn fixtures, sample data, demo content or implementation choices into requirements.
- Use Git for history. No decision logs, no changelogs, no dated "what changed" notes in specs or plans.

## Docs

`docs/` is for a human who won't read much: diagrams first, a sentence where a diagram can't say it, one page per subject, no history. A round that changes a route, a table, a wire shape, a protocol or the path between the app and the service updates the matching page in the same round. At the end of every phase a documentation round reads the code as committed and brings `docs/` back in line, as Mermaid diagrams and tables cut to what a newcomer needs. Nothing else goes there: no reports, no decision logs, no copies of `AGENTS.md` or the plans. If a page grows past a screen or two, split or cut it; if two pages say the same thing, keep one.

## Toolchain

Node is pinned in `mise.toml` and locked in `mise.lock`: run `mise install`, then `npm ci`. The root `.npmrc` sets `min-release-age=7` and `strict-allow-scripts=true`; the root `package.json` records exact-version install-script reviews in `allowScripts`. When an updated dependency needs a new review, extract it with `npm ci --ignore-scripts`, inspect its install scripts and immediate helpers, and record an exact-version decision. Never bypass either protection or grant blanket approvals to get an install through. To bump Node, edit `mise.toml`, run `mise lock` and the full test suite.

## Agent skills

The agents' skills are committed, so every session and worktree has them with no setup: the files are in `.agents/skills/`, where Codex reads them; `.claude/skills/` links to each one for Claude Code; `skills-lock.json` pins their versions. Skills are instructions from outside the repository: follow them for patterns, never over the specs, the plans or an `AGENTS.md`. A skill that ends by sending feedback or telemetry to its vendor doesn't do so unless Pierre asks.

## Secrets

Account tokens live on Pierre's Mac in `~/.config/<project>/agents.env`, mode 600, beside the release secrets; never in the repository, never in a brief. A command that needs them runs in a shell that loaded the file first (`set -a; . ~/.config/<project>/agents.env; set +a`), for that command only.
