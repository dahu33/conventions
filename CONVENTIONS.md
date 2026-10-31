# Conventions for every project

Pierre's standing rules for all his repositories, copied into each project's `AGENTS.md` by this repository's `sync.sh`. The rest of a project's `AGENTS.md` adds what is specific to that project and never contradicts these. Where a rule says "the specs" or "the plan", it means the project's `specs/` and `plans/`.

## Agent instruction files

- `AGENTS.md` is the single source of truth for agent instructions.
- Always create and edit `AGENTS.md` directly, never `CLAUDE.md`.
- Whenever creating an `AGENTS.md` file, including in nested directories, also create a `CLAUDE.md` symlink pointing to it in the same directory (`ln -s AGENTS.md CLAUDE.md`).
- Never create standalone `CLAUDE.md` files or duplicate instruction content.
- If `CLAUDE.md` already exists, verify that it is the correct symlink. Never overwrite an existing regular file without reconciling its contents first.
- An instruction file holds rules and commands only, rules first, so a reader that stops early still has them: no description of the code beyond where things are, no history, no reasoning.
- An `AGENTS.md` holds what applies to every edit in its scope. The rules of one module live in a nested `AGENTS.md` beside its code, which the parent file names.
- A procedure needed only now and then (a release, a simulator recipe) is a repository skill, loaded on demand, not text in an `AGENTS.md`.
- No repository file, an agent definition included, prescribes an agent model or reasoning effort: they are chosen outside the repository.

## Spend

Nothing that costs money without an explicit request from Pierre: no paid plan, developer program, store account, mail service, build minutes, library licence or any other paid service. Free tiers are fine where the project's specs allow them. Nothing is deployed and nobody logs in to a provider until Pierre asks.

## Align before writing

The specs record Pierre's explicit statements, what he approved, and assumptions marked as such. Anything else a session fills in goes to Pierre as a proposal, or into the owning spec marked as assumed and into the report, where the project allows that. Ask Pierre only about ambiguities or conflicts the specs don't resolve. An absent or open requirement is not permission to invent one: make the simplest reversible choice, report it, and Pierre decides. Agreeing with a design, a spec or a plan is not saying to build: a milestone starts on Pierre's explicit confirmation.

## One pull request per milestone

Each milestone is its own branch, started from `origin/main` after a fetch (never from a local `main`, which may be stale), pushed, and merged into `main` on GitHub as its own pull request as soon as it is reviewed and verified; milestones are never batched. A branch is brought up to date once, right before it merges, by merging `origin/main` into it (never a rebase, never a force push). If the merge brought nothing, merge. If it did, rerun the typecheck and the lint; rerun a test suite only when the merge touched the same workspace as the branch or needed a conflict resolved. Merge with a squash (`gh pr merge --squash`, the only method the repository allows; head branches are deleted on merge): `main` holds one verified commit per milestone, titled like the pull request. The plan's status row is edited only in that final update, by whoever merges, so in-flight branches don't conflict on it. Commits and pull requests carry no agent attribution (no co-author trailer, no "generated with" line); a project that uses Claude Code sets `"attribution": {"commit": "", "pr": ""}` in `.claude/settings.json`.

## Verification is local and complete

Nothing runs on push or pull request: GitHub's build minutes are not spent, and a CI workflow, where one exists, runs on manual dispatch only and is neither verified nor maintained until Pierre brings CI back. Each project's `AGENTS.md` names its full verification, the checks to run while building, and the paths that count as specs and docs.

- **While building**, whoever implements (a build round, a fix round) runs the checks for what they touched, as the project's `AGENTS.md` defines it; they don't replace the full verification before merge. A change to dependencies or lockfiles, toolchain pins, shared, build or test-runner configuration, or shared test setup touches everything: it gets the full verification.
- **Before merge**, one full verification covers the final tree, normally run by whoever merges, right after bringing the branch up to date; an earlier full run counts only while it is still valid.
- **A result belongs to the commit it ran on.** It stays valid across two changes only: bringing the branch up to date, with the reruns "One pull request per milestone" asks for when the update brought commits, and later commits confined to the specs and docs paths, checked as below. Any other edit makes it stale, and nobody reports green from a stale result.
- **The pull request body** records the final gate: for each run, the commit, the exact commands and each result. Reviewers compare the recorded commit with the head and run only the targeted checks their own doubts call for, never the full suite as ritual.
- **Specs and docs only:** a pull request whose whole diff against its base stays within the project's specs and docs paths needs no full run. It, like a commit within those paths after a full run, gets `git diff --check` over the branch's whole diff, committed and uncommitted, and every relative link and anchor in the files touched resolves; a command it adds or changes runs once, or a cheap probe of it, and the report says which.

Whatever else a change touches, every relative link and anchor in the specs and docs files it touches resolves.

## Rounds and reports

A brief names what its round changes (screens, flows, routes, tables), the scenarios to check and the evidence it carries over.

- **Evidence carries over** within a building round while its inputs are unchanged: a targeted check that passed on the same code, and on the same binary for a native check, is cited by its path and the commit it ran on, as evidence from that commit, not repeated and not a pass on the new commit. After a fix, rerun what failed and what covers the code the fix touched; an interrupted round resumes from its saved evidence and runs only what has no result yet. The full verification before merge never carries over this way.
- **Code merged from `origin/main`** was verified in its own pull request: the merge puts at risk only the conflicts it resolved, the native code it brought and the places the round's change meets it. Check those, not the merged feature.
- **Copy and translations** change what a screen says, not what it does: check the wording and its fit on each changed screen, not the feature behind it unless the round changed its code.
- **Screenshots of a UI change.** A round that changes what a screen shows or how it behaves ends with one screenshot of each changed screen in its final state, default theme, kept small (about 400 px wide): the round looks at it to check what the accessibility snapshot can't show (layout, overlap, clipping, colour), shows it in the chat and attaches it to the pull request (`gh pr create` or `gh pr edit` with `--attach '<file>#<alt text>'`, gh 2.99 or later). One platform for a change common to the mobile app, iOS by preference; a change specific to Android or the web adds one there. A before-and-after only on request.
- **The round stops** when the while-building checks have run on the final tree and each named scenario has a result: passed, failed with its evidence, or not done with the reason. A failure in what the round changed is fixed and rerun in the round; any other is reported, never waived, skipped or given a longer budget. A finding outside the round's scope is its own item in the report, not a reason to add checks.

Every report is brief and gives: what was built or changed, by screen, flow, route or table; each command run and its result, and what was not run or not verified; what needs a real device (GPS, background work, sensors, battery, airplane mode), which is Pierre's to check; the choices made where the specs were silent; contradictions found in the specs; libraries added, with versions and why; migrations added, with the fixture that proves each.

## Tests and design checks

- No test snapshots a rendered tree: tests assert what a person perceives (the words, labels, roles and states, what a control does). A snapshot, where one is kept, holds wording only and changes only when the wording changes on purpose.
- Colours come only from the theme's tokens: a lint rule rejects a colour literal outside the theme, and a test holds every colour pair a screen draws at WCAG AA in every theme the app has.
- Build rounds check screens in the default theme at the default text size: text follows the system size and no round checks it; another theme is held by the lint and the contrast test. A device pass at the largest text size, and in each other theme, before the first public store release is recommended, not required.

## Test devices

Pierre's Mac has four test devices and no others: the iOS simulators `iphone-1` and `iphone-2` and the Android emulators `pixel-1` and `pixel-2`, driven through the device tools or the `agent-device` CLI, one device per task.

- A booted device belongs to another session: never take it over. Boot one that is powered off (Shutdown in `xcrun simctl list devices`, absent from `adb devices`); when both of a platform are booted, wait or report the check as not done, never start a third.
- Power it off when done, after a failure too (the device tool's shutdown, `xcrun simctl shutdown <udid>` or `adb -s <serial> emu kill`): a device left on blocks the next session.
- Never create, clone, rename or delete a simulator, an AVD, a runtime or a system image.
- Metro runs on a port of the session's own (`--port`), never 8081. An iOS build also sets `RCT_METRO_PORT=<port>`, or its relaunch asks 8081, another session's Metro.
- The accessibility snapshot first; a screenshot, kept small, only for what a snapshot can't show, such as the screenshots of a UI change.

## Data always moves forward

Every change to the shape of stored data (a table, a stored JSON document, a setting's value, any stored object) ships as a numbered, forward-only migration that rewrites existing data to the new shape, and product code knows one shape only. No compatibility branch, no read-time converter, no optional field standing in for a migration. A committed migration is never edited. What is a cache of something stored elsewhere is rebuilt or re-fetched, not migrated. Every brief that changes a stored shape names the migration; the builder's tests load a fixture of the previous shape and check it migrates. Names follow the project's naming rules; a new name that fits no row there is a question for Pierre.

An app updated over the air ships its local migrations in updates, not only with store builds, under four rules:

- The migrations run after the app's first view has drawn, so the update manager counts the launch and never rolls back onto migrated data.
- Code never opens local data newer than itself: a release build shows a page asking to update, or to reopen later, touches nothing, and ends with the app's version, its update and both data versions; a development build carries on.
- Native code that reads or writes that data checks a contract version of its own, which only a migration changing what it touches raises: only that migration needs a store build.
- A broken update is fixed forward: a rollback or a revert never crosses a migration.

## Environments are separable

- Every stateful thing is per environment: the databases, the stores (files, caches, queues), the secrets, the mail sender, the domain and the trusted origins. Two environments never share one.
- Product code knows no environment name: it reads its bindings and variables, the deploy configuration alone decides the environment, and the same build runs in every one.
- An environment is created from configuration and a script (provision the stores, apply the migrations, put the secrets, deploy), never by hand; tearing one down leaves nothing behind.
- Data moves between environments only by an explicit export and import, never by sharing.
- Everything runs locally with every binding simulated: no code path works only when deployed, and no environment switches identity or auth off.

## Specs

- Each requirement lives in exactly one file; other files link to it. Every spec separates confirmed behaviour, what is assumed or under exploration, and open questions.
- When Pierre states or changes a requirement, the owning spec is updated in the same task: replace contradicting wording, update the specs that depend on it, keep what the change didn't touch. When he answers an assumption, it becomes confirmed.
- Feedback on presentation changes the design direction. It doesn't imply new functional requirements.
- Never turn fixtures, sample data, demo content or implementation choices into requirements.
- Use Git for history. No decision logs, no changelogs, no dated "what changed" notes in specs or plans. A finished milestone in a plan keeps its title only; its detail is in Git.

## Docs

`docs/` is for a human who won't read much: diagrams first, a sentence where a diagram can't say it, one page per subject, no history. A round that changes a route, a table, a wire shape, a protocol or the path between the app and the service updates the matching page in the same round. At the end of every phase a documentation round reads the code as committed and brings `docs/` back in line, as Mermaid diagrams and tables cut to what a newcomer needs. Nothing else goes there: no reports, no decision logs, no copies of `AGENTS.md` or the plans. If a page grows past a screen or two, split or cut it; if two pages say the same thing, keep one.

## Issues

- **Labels**, one of each per open issue, no others without Pierre: `source:feedback` (an app's Feedback button) or `source:manual`; `kind:bug`, `kind:enhancement` or `kind:other`; `status:triage` (unread), `status:needs-decision` (waiting on Pierre), `status:ready` (accepted) or `status:on-hold` (wanted but not now, or blocked, the reason in a comment), the last two set by Pierre only. Reading a triage issue moves it to `status:needs-decision`. Closing removes the status; a duplicate gets `Duplicate of #N` and is closed as one.
- **Opening one:** search open issues first and comment on a match. A one-line title; a body of a few lines, no headings: for a bug, what happens, what was expected, how to see it, where (platform, version and build, or environment); for an idea, what and why, in the reporter's words. Observed evidence (an error, a log line) is fine.
- **Triage notes:** an automated triage may post one comment on a `status:triage` issue, starting with the model and effort that wrote it (`sol-6.1-xhigh:`): evidence, and for Pierre's decision the likely cause, feasibility and options, with a diagram or mockup where it speeds the decision. It then moves the issue to `status:needs-decision`, and changes nothing else.
- **Never in an issue**, outside triage notes and unless explicitly requested or approved: a guessed cause, a fix, an implementation, a design, scope, acceptance criteria, tasks or a decision. Never the reporter's email, name or account id.

## Toolchain

Node and the package manager the root `package.json` declares (`packageManager`) are pinned in `mise.toml` and locked in `mise.lock`: run `mise install`, then the manager's install below. Whatever the manager, two protections hold: no dependency release younger than seven days is installed, and an install script runs only after an exact-version review recorded in the root `package.json`'s `allowScripts` (`true` for a hook that is needed, `false` for one that stays blocked).

- **npm:** the root `.npmrc` sets `min-release-age=7` and `strict-allow-scripts=true`; install with `npm ci`, extract for a review with `npm ci --ignore-scripts`.
- **Bun:** `bunfig.toml` sets, under `[install]`, `minimumReleaseAge = 604800` (seconds), `minimumReleaseAgeExcludes = []` and `ignoreScripts = true`; `trustedDependencies` in `package.json` stays `[]`. Install only through the project's guarded installer, which runs `bun install --frozen-lockfile --ignore-scripts`, then only the hooks with an exact-version `true`, and fails on a script with no decision before any runs; extract for a review with `bun install --ignore-scripts`. The `.npmrc` above stays, so a one-off `npx` tool keeps both protections.

When an updated dependency needs a review, extract it without scripts, inspect its install scripts and immediate helpers, record an exact-version decision, then rerun the install and commit the lockfile. Never bypass either protection to get an install through: no blanket approval, no cooldown exemption, no `bun pm trust`. To bump Node or the package manager, edit `mise.toml` (and `packageManager`), run `mise lock` and the full test suite.

## Agent skills

The agents' skills are committed, so every session and worktree has them with no setup: the files are in `.agents/skills/`, where Codex reads them; `.claude/skills/` links to each one for Claude Code; `skills-lock.json` pins their versions, and the repository's own skills sit beside them with no entry there. A vendor's skills are instructions from outside the repository: follow them for patterns, never over the specs, the plans or an `AGENTS.md`. A skill that ends by sending feedback or telemetry to its vendor doesn't do so unless Pierre asks. Skills considered and not installed are listed, each with the reason to add it, in `.agents/skills/README.md`, not in `AGENTS.md`.

## Search noise

A root `.ignore` file names what repository-wide searches skip (ripgrep reads it, and both agents search with it): generated or vendored files and bulk data such as translations or raw results. An explicit path still searches them. A large generated file is built by its script and gitignored, never committed.

## Secrets

Account tokens live on Pierre's Mac in `~/.config/<project>/agents.env`, mode 600, beside the release secrets; never in the repository, never in a brief. A command that needs them runs in a shell that loaded the file first (`set -a; . ~/.config/<project>/agents.env; set +a`), for that command only.
