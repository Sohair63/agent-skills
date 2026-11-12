# Global instructions (all projects)

## Start of every task

Before planning or writing code for any task, load the `task-preflight` skill (`~/.claude/skills/task-preflight/SKILL.md`) and follow it. If the project has its own architecture or audit skill, run that one as well. Act as the system architect and senior reviewer on the change: understand it end to end, settle every product decision up front (infer from the code first, then ask everything else in one round), pre-think the code and the PR, then build it complete. Skip only for typos, copy-only edits, log lines and agent-config edits.

## Migration timestamps

When creating a database migration file, always use the actual current timestamp for the filename prefix (run `date +%Y%m%d%H%M%S`, or `bin/rails generate migration`, which does this). Never hand-write a rounded time like `20260825090000` (9am of the current day). Fabricated timestamps have caused migration ordering conflicts between branches and will again.

## Client messages

When Sohair forwards a message from a client, first decide whether it needs a reply, even a short acknowledgement, and draft that reply before anything else. Write replies in Sohair's voice, in the first person ("I"), not "we".

Never start implementation while the conversation with the client is still open. Close it first (questions answered, direction confirmed, reply sent), then build. Settling things up front avoids rework and saves tokens.

## Code quality

Write clean, high-quality code that solves the problem simply. Do not overcomplicate it.

## Walkthrough recordings

Record every walkthrough video at the current machine's full screen size, never a smaller viewport that looks zoomed in. Read the size first (`osascript -e 'tell application "Finder" to get bounds of window of desktop'`; on this Mac it is 1728×1117 points, Retina) and use it for both the browser viewport and the video size.

Whenever asked to create a walkthrough video, record it with a Playwright script (Playwright's `recordVideo`, driven by a script), not Claude in Chrome, a GIF, or manual screen capture.

Save each finished video on the Desktop inside a folder named after the project it belongs to, so videos from different projects stay separate: `~/Desktop/<project-folder>/`, where `<project-folder>` is the repo's directory name (e.g. `~/Desktop/journey-tracker/`). Create the folder if it does not exist. Prefix the filename with the date so the folder sorts in recording order: `YYYY-MM-DD-<feature>-walkthrough.mp4` (e.g. `2026-10-18-studio-notifications-walkthrough.mp4`). Never leave a walkthrough loose on the Desktop.
