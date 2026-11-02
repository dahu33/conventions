---
name: release-notes
description: Draft an app version's release notes for its users from what merged since the previous version, and write them to the project's notes file. Called by name, or from the project's release skill when a version is raised.
disable-model-invocation: true
---

# Release notes

The rules are the **Release notes** convention in the project's `AGENTS.md`: what never goes in, at most five items, English first. This skill is how to apply them. The project's release skill names the notes folder, where the app's version is set, how to find the previous release's commit, and the translation rule; when it doesn't, stop and ask Pierre.

## The file

One file per version, `<notes folder>/<version>.json`, never edited once that version is released:

```json
{
  "version": "1.4.0",
  "items": [
    {
      "kind": "new",
      "icon": "search",
      "title": { "en": "Search history" },
      "text": { "en": "Delete a single search from your history, or clear it all." }
    },
    {
      "kind": "fixed",
      "icon": "edit",
      "title": { "en": "Forms keep your text" },
      "text": { "en": "Text typed in a form is no longer lost when the keyboard closes." }
    }
  ]
}
```

- `version` is the app's version, as its config sets it.
- `kind` is `new`, `improved` or `fixed`. Items go in that order, the most noticeable first within a kind.
- `icon` is one of the names in `<notes folder>/icons.json`, the project's list: the one that best says what the item is about.
- `title` is a headline of two to four words, at most 30 characters in English, no full stop: what a person scanning the list reads first. `text` is one sentence ending in a full stop, at most 90 characters in English, that says what it does for them; it stands alone, without the title (the store text uses it alone). Both are keyed by the app's language tags: `en` always, others as the translation rule says.
- `items` is empty when nothing in the version is for users; the app then shows nothing.
- After an update the app lists the new and improved items of every version not yet shown, and sums up the fixed ones in a line; it opens nothing for a version that only fixes. Every item stays readable in the app's list of versions.

## Steps

1. **The range.** Fetch, then take the commits from the one that added the previous version's notes file (`git log -1 --diff-filter=A --format=%H -- '<notes folder>/<previous version>.json'`) to `origin/main`. With no earlier file, start at the previous release's commit.
2. **What merged.** `git log --first-parent --format='%h %s' <from>..origin/main` lists one squash commit per pull request. For each, `gh pr view <n> --json title,body,closingIssuesReferences`; an issue it closes labelled `source:feedback` was reported by a user, so its fix is worth an item. Read the diff only when the title and body don't say what a user sees.
3. **Sort each pull request**:
   - **For users**: a screen, a control, a flow, a wording, a map or data source, anything a user meets. It becomes an item.
   - **Felt**: internal work with an effect a user can notice (faster, smaller, less battery, fewer crashes, works offline, updates arrive without the store). It becomes an item saying the effect, never the cause.
   - **Internal**: everything else. No item.
   - **Not public**: a feature that is unreleased or still hidden (behind a switch, for testers only, unreachable). No item; it waits for the version that shows it.

   An item never carries a detail the convention's "Never" list names: leave the detail out and keep the effect (a security fix is "security improved", a faster provider is "faster"). Several pull requests can make one item. A bug introduced and fixed within the range is not an item.
4. **Cut to five**: merge related items, drop the least noticeable.
5. **Write for someone who uses the app**: what they can now do, or what now works, with the names the app's screens show. Plain words, "you" where it helps, no jargon, no marketing words, no exclamation marks. Name a platform only for an item that concerns one ("On Android, …"). A title names the thing as the app's screens do ("Download along a route", not "Corridor downloads v2").
6. **Check each item against the "Never" list.** As a last net, search the titles and texts for `#`, `/`, backticks, `@`, camelCase and version numbers; each hit is a leak until shown otherwise.
7. **Translate** only where the translation rule asks for it now, titles and texts alike; otherwise English alone.
8. **Commit** the file in the pull request that raises the version. Add a table to its body: each pull request in the range, and what became of it (item 2, merged into item 2, internal, not public), so Pierre can check both before the release.

## Store text

A store build's release text (Play's release notes, TestFlight's "What to Test", later the App Store's "What's New") comes from these files, assembled by the project's release lane:

- the items of every version after the one the previous store build carried, up to the version built, newest version first;
- one line per item, its text alone, starting with `• `; an item repeated in two versions is kept once, from the newest;
- per language, cut by whole items from the oldest version to fit the store's limit (500 characters on Play, 4,000 on the App Store); a language without a text gets the English one;
- no items, no text: the field stays empty.
