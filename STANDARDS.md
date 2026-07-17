# Karthik's coding standards and rules

These are the standards and rules for all Karthik's projects regardless of framework or language.

## Core Philosophy

- Code must be simple, readable and maintainable, no over engineering
- Build for the requirement in front of you, not the one you imagine later (YAGNI)
- Keep naming simple, clear, names reveal intent
- Make it work, make it right, make it fast, in that order
- Don't optimize before you measure, guessing at hotspots wastes time and adds complexity for nothing

## Functions

- Keep it small, one level of abstraction per function
- Fewer arguments is better, if more bundle into a model/struct
- Clear separation, one function does one thing only
- No hidden side effects behind an innocent name (Command-Query Separation)

## Structure

- Prefer deep modules over shallow modules (simple interface, does real work behind it)
- Follow SOLID principles
- DRY - one authoritative source for each piece of knowledge, not just "no copy paste"
- No broken windows, small decay left alone invites more decay

## Error Handling

- Fail fast and loud on programmer errors (bad input, broken invariants)
- Fail gracefully with a useful message on expected runtime failures (network, I/O, user input)
- Never swallow errors silently, no empty catch blocks
- Never return null/None as a stand-in for "not found", use an explicit type

## Documentation

- Code is documented with google style doc-strings
- Doc-strings are minimal and clear, no need to explain code/decisions in doc-strings
- One line comments tell decisions and intent, only when necessary for Karthik to know it

## Testing

- Test behavior, not implementation, refactors shouldn't break tests unless behavior changed
- A flaky or untrusted test is worse than no test, fix it or flag it, don't ignore it

## Version Control

- Commit small, one logical change per commit, not a dump of unrelated edits
- Commit message says why, not just what
- Never commit secrets, credentials or generated build output, gitignore them from day one
- Commit the lockfile, a build that only works on my machine is not reproducible
- Don't commit commented-out code, delete it, git remembers it for me

## Dependencies

- Add a dependency only when it earns its weight, a few lines of my own often beats a whole library
- Pin versions, unpinned deps break silently on the next machine
- Drop deps I stopped using, dead weight rots

## Configuration

- Config comes from the environment, not hardcoded in source
- Same build runs in dev and prod, only the config changes
- Secrets live outside the repo, always (see AGENTS.md security)
