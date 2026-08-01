# Karthik's coding standards

Applies to every project, any language or framework.

## Core

- Simple, readable, maintainable. No over engineering.
- Build for the requirement in front of you, not the one you imagine later (YAGNI).
- Names reveal intent and stay plain.
- Make it work, make it right, make it fast, in that order.
- Measure before optimizing. Guessing at hotspots buys complexity and nothing else.

## Functions

- Small, one level of abstraction, one job.
- Fewer arguments. More than a few means they belong in a struct or model.
- No hidden side effects behind an innocent name (Command-Query Separation).

## Structure

- Deep modules over shallow ones: simple interface, real work behind it.
- Follow SOLID.
- DRY means one authoritative source per piece of knowledge, not just "no copy paste".
- No broken windows. Small decay left alone invites more.

## Errors

- Fail fast and loud on programmer errors: bad input, broken invariants.
- Fail gracefully with a useful message on expected runtime failures: network, I/O, user input.
- Never swallow an error. No empty catch blocks.
- Never return null or None to mean "not found". Use an explicit type.

## Documentation

- Google style doc-strings, minimal and clear. They say what, not why.
- Inline comments carry decisions and intent, and only where Karthik would
  otherwise have to guess.
- Prose in code and docs follows ~/dotfiles/VOICE.md.

## Testing

- Test behavior, not implementation. A refactor should not break a test unless
  behavior changed.
- A flaky test is worse than no test. Fix it or flag it, never ignore it.

## Version control

- One logical change per commit, not a dump of unrelated edits.
- Commit message format and rules live in ~/dotfiles/AGENTS.md.
- Never commit secrets, credentials or build output. Gitignore them from day one.
- Commit the lockfile. A build that only works on one machine is not reproducible.
- Delete commented-out code. Git remembers it.

## Dependencies

- Add one only when it earns its weight. A few lines of your own often beat a library.
- Pin versions. Unpinned deps break silently on the next machine.
- Drop deps you stopped using.

## Configuration

- Config comes from the environment, never hardcoded.
- Same build in dev and prod, only config changes.
- Secrets live outside the repo, always (see AGENTS.md security).
