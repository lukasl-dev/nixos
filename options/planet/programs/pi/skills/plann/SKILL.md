---
name: plann
description: Manage CalDAV calendars and tasks with the configured `plann` CLI. Use for listing calendars, checking agendas, finding events or todos, and adding, editing, completing, postponing, or deleting calendar objects.
compatibility: Requires the configured plann CLI and network access to the CalDAV server.
metadata:
  hermes:
    tags: [calendar, caldav, events, tasks]
---

# Plann CalDAV CLI

Use `plann` to work directly with the configured CalDAV account. The local wrapper already supplies the credential-bearing configuration file; never read that file, expose its contents, or pass credentials on the command line.

## Core behavior

- `plann` talks directly to the server. There is no local synchronization cache and mutations take effect immediately.
- Global options go before the main command. Selection filters go between `select` and its action:

  ```bash
  plann [GLOBAL_OPTIONS] select [FILTERS] list [LIST_OPTIONS]
  ```

- Calendar discovery occurs at the start of every invocation. Even some nested `--help` calls may contact the server.
- If several calendars are available, additions may prompt or duplicate objects. Select one explicitly by name.
- A UID lookup checks every configured calendar. The same UID can therefore select more than one object unless the command is also scoped with `--calendar-name`.
- `select edit` saves every selected object, even if no useful edit option was supplied.
- Deleting one selected object has no CLI confirmation. Deleting several prompts unless `--multi-delete` is given.
- The `interactive` command family is experimental and expects a human TTY. Do not use it from an unattended or messaging session.

## Safety rules

1. Start with a read-only query and inspect its output.
2. For edits, completion, postponement, and deletion, resolve the intended object to both a calendar name and a UID, then preview it first.
3. Never mutate a broad selection unless the user explicitly requested the exact bulk operation after seeing its scope.
4. Never use `select --all` for a mutation.
5. Never use `--multi-delete`.
6. Ask for explicit confirmation immediately before deletion, even though the CLI may not ask.
7. Do not use `--caldav-pass` or `--caldav-password`; command-line secrets can leak through process listings and logs.
8. Preserve the UID printed by an add operation and use it to verify the result.

## Read-only operations

List calendars without an interactive pager:

```bash
PAGER=cat plann list-calendars
```

Show the convenience agenda (upcoming events followed by tasks):

```bash
plann agenda
```

List today's events:

```bash
start="$(date +%F)"
end="$(date -d tomorrow +%F)"
plann select --event --start "$start" --end "$end" list
```

List events over the next seven days:

```bash
plann select --event --start "$(date --iso-8601=seconds)" --end +7d list
```

List incomplete tasks due within seven days:

```bash
plann select --todo --exclude-completed --end +7d list
```

Search by summary, then inspect the returned objects before doing anything else:

```bash
plann select --summary "search text" list
```

Preview one exact object by UID:

```bash
plann --calendar-name "$calendar" \
  select --uid "$uid" --abort-on-missing-uid list
plann --calendar-name "$calendar" \
  select --uid "$uid" --abort-on-missing-uid print-ical
```

Use `--limit N` and `--offset N` on `select` for large result sets. Add `--template FORMAT` after `list` only when the normal output lacks a needed field.

## Time syntax

Prefer unambiguous ISO dates and timestamps. Quote the whole timespec.

- All-day event: `2026-07-20+1d`
- Timed event with duration: `2026-07-20T14:00+02:00+2h`
- Explicit start and end: `2026-07-20T14:00+02:00 2026-07-20T16:00+02:00`
- Relative selection bounds: `+2h`, `+7d`
- Duration units: `s`, `m`, `h`, `d`, `w`, `y`

Naive timestamps use the machine's local timezone. Prefer an explicit numeric offset, or supply a known IANA timezone globally:

```bash
plann --implicit-timezone Europe/Vienna ...
```

Despite examples in its own help text, plann 1.0.0 does **not** parse the words `now` or `today`. Use GNU `date` to produce an ISO value as shown above. A relative `+duration` works as a `select` bound, but not as an event's complete timespec.

## Add an event or task

First list calendars and choose the intended display name. Put `--calendar-name` before `add`, and use `--first-calendar` to avoid an interactive choice after the name filter:

```bash
PAGER=cat plann list-calendars
plann --calendar-name "$calendar" add --first-calendar event \
  "$summary" "$timespec"
```

Optional event attributes belong after `event`:

```bash
plann --calendar-name "$calendar" add --first-calendar event \
  --set-location "$location" \
  --set-description "$description" \
  "$summary" "$timespec"
```

Add a task:

```bash
plann --calendar-name "$calendar" add --first-calendar todo \
  --set-due "$due" \
  "$summary"
```

Both add commands print `uid=...`. Capture that UID and verify it:

```bash
plann --calendar-name "$calendar" \
  select --uid "$uid" --abort-on-missing-uid list
```

If the calendar name is unknown or ambiguous, stop and ask rather than choosing a calendar implicitly.

## Edit, complete, or postpone

Always preview the UID first. Then perform one focused mutation:

```bash
plann --calendar-name "$calendar" \
  select --uid "$uid" --abort-on-missing-uid list

plann --calendar-name "$calendar" \
  select --uid "$uid" --abort-on-missing-uid edit \
  --set-summary "$new_summary"

plann --calendar-name "$calendar" \
  select --uid "$uid" --abort-on-missing-uid edit \
  --set-location "$new_location"

plann --calendar-name "$calendar" \
  select --uid "$uid" --abort-on-missing-uid edit \
  --postpone 2d

plann --calendar-name "$calendar" \
  select --uid "$uid" --abort-on-missing-uid complete
```

Other useful edit flags include `--set-description`, `--set-dtstart`, `--set-dtend`, `--set-due`, `--set-priority`, `--set-status`, `--cancel`, and `--uncomplete`. Verify the UID after mutation with another read-only `list` or `print-ical` call.

Recurring completion defaults to the CLI's `safe` recurrence mode. Do not choose another recurrence mode unless the user explicitly asks and understands the series-wide effect.

## Delete

Deletion is irreversible and a single-object deletion does not prompt. Follow this exact flow:

1. Select exactly one calendar and UID with global `--calendar-name` and `--abort-on-missing-uid`.
2. Show its summary, time, calendar, and UID to the user.
3. Ask for explicit deletion confirmation.
4. Only after confirmation, run:

   ```bash
   plann --calendar-name "$calendar" \
     select --uid "$uid" --abort-on-missing-uid delete
   ```

5. Verify absence with a read-only UID lookup. Do not broaden the selector if the UID is missing.

## Troubleshooting

- `Giving up: No calendars given`: verify server reachability and run `PAGER=cat plann list-calendars`.
- Multiple-calendar prompt: rerun with a specific global `--calendar-name` and `add --first-calendar`.
- Missing UID silently ignored: add `--abort-on-missing-uid`.
- Unexpected mutation scope: stop; rerun the same filters with `list`, collect exact UIDs, and obtain confirmation.
- Nested `--help` contacts the server or aborts before showing help: this is normal for plann 1.0.0 because calendar discovery runs before subcommands.
- There is no `--version` option in plann 1.0.0; use `plann --help` to test that the executable is available.
