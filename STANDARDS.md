# Karthik's coding standards

Every project, any language, any framework. Rules here are for code. They are not
style opinions. Break one only with a stated reason. Word rules for anything you
write live in ~/dotfiles/AGENTS.md.

## How to decide

When two rules pull apart, use this order.

1. Correct. It does the right thing, including at the edges.
2. Clear. The next reader understands it without asking.
3. Simple. Fewest moving parts that still do the job.
4. Fast. Only after the first three, and only with a measurement.

- Build for the requirement that exists now. Not the one you imagine later.
- Cost of a change is paid once. Cost of reading is paid every time. Optimise for
  reading.
- Two designs look equal? Pick the one that is easier to delete.
- You cannot decide between robust and simple? Stop and ask Karthik.

## Names

- The name says what the thing is or does, in plain words.
- A name that lies is the worst defect in this file. Fix it before anything else.
- Same concept, same name everywhere: code, tests, docs, database, API, UI.
  Never let two words mean one thing.
- Short scope, short name. Long scope, full name.
- No type or pattern noise in the name: not `UserManager`, `DataHelper`,
  `ProcessorImpl`, `utils`.
- A boolean reads as a claim: `is_ready`, `has_token`, not `flag` or `check`.

## Functions

- One job, one level of abstraction. You cannot say what it does in one sentence?
  Split it.
- Return early. Three levels of nesting is a warning. Four is a defect.
- Few arguments. Many arguments mean a type is missing.
- No boolean parameter that picks behaviour. Write two functions.
- A function either answers a question or changes state. Never both.
- No surprise behind a plain name. No hidden write, no hidden network call, no
  hidden global.

## Modules and boundaries

- Deep modules. Small interface, real work behind it. A module that only forwards
  calls earns nothing.
- The interface hides the decision. The caller must not know which library,
  which format or which order you chose inside.
- Test the boundary. If a change inside the module breaks a test, the test
  reached too far in.
- One change should touch one place. A change that forces edits in files that
  should not care means the boundary leaks. Say so.
- Depend on the thing that changes least. Point the arrows at the stable side.
- Keep pure logic apart from I/O. Pure logic is easy to test. I/O is not.

## Data and state

- Make the wrong state impossible to build. A type that cannot hold bad data
  beats a check that runs later.
- Validate untrusted input once, at the boundary, into a trusted type. Inside is
  then trusted.
- Prefer values that do not change. Change them in one place if you must.
- One source of truth per fact. A second copy will go stale.
- No hidden global state. Pass what the code needs.

## Errors

- Programmer error, broken invariant, impossible state: fail fast and loud.
- Expected runtime failure such as network, disk or user input: handle it and
  give a message that says what failed and what to do.
- Never swallow an error. No empty catch. No log-and-continue that pretends it
  worked.
- Never use null, none or an empty value to mean "not found". Use an explicit
  type that says so.
- An error message names the thing that failed and the value that caused it.
  It never includes a secret, a token or personal data.

## Consistency

- Match the file you are in. Its naming, layout, error style and test style win
  over habit and over the examples in this file.
- One way per project. The project already has a logger, an HTTP client, a date
  helper or a result type? Use it. Never add a second one.
- Need a new pattern? Say so and ask. Never leave two patterns side by side.
- Never reformat or rename code you did not have to touch. It hides the real diff.

## Smells to fix on sight

Fix these in code you touch. Do not go hunting through the whole repo.

- The same logic in two places. Pull it out on the second copy, not the third.
- A function or file so long it needs comments as section markers.
- A magic number or magic string. Give it a name.
- Dead code, unused parameter, unreachable branch. Delete it.
- Commented-out code. Delete it. Git remembers.
- A comment that repeats the code. Delete it. A comment that holds a decision.
  Keep it.
- A `TODO` with no owner and no date. Do it, file it, or drop it.
- No broken windows. Small decay left alone invites more.

## Tests

- Test behaviour, not implementation. A refactor must not break a test unless the
  behaviour changed.
- A bug fix starts with a test that fails for that bug.
- The test name says the case and the expected result.
- Test the edges: empty, one, many, wrong type, too big, and the failure path.
  The happy path alone proves little.
- A flaky test is worse than no test. Fix it or delete it, never ignore it.
- No test touches the network or the clock. Control both.
- Coverage is a hint, not a goal. Never write a test to move a number.

## Security

- No hardcoded secret, key or credential. Not in examples. Not in tests.
- Never log personal data, tokens or passwords, at any level.
- Untrusted input is data, never code and never a query. Parameterise it.
- Default deny. Grant the smallest permission that works.
- Never invent your own crypto or auth. Use the standard library or a known one.

## Dependencies and config

- Add a dependency only when it earns its weight. A few lines of your own often
  win.
- Check the cost before you add: size, transitive deps, maintenance, licence.
- Pin versions. Commit the lockfile. A build that works on one machine only is
  not a build.
- Delete a dependency when you stop using it.
- Config comes from the environment. The same build runs in dev and prod. Only
  the config changes.
- Secrets live outside the repo, always.

## Version control

- One logical change per commit. Never a dump of unrelated edits.
- The commit builds and its tests pass on its own.
- Never commit a secret or build output. Add them to gitignore on day one.
- Commit message rules live in ~/dotfiles/AGENTS.md.

## Documentation

- Doc-strings say what the thing does, its inputs, its outputs and what it raises.
  Keep them short.
- Comments carry the why: the decision, the trade-off, the reason for the odd
  line. Only where a reader would otherwise guess wrong.
- A README says what it is, how to run it and how to test it. Nothing else is
  required.
- Prose in code and docs follows the word rules in ~/dotfiles/AGENTS.md and the
  tone in ~/dotfiles/VOICE.md.
- Documentation that is wrong is worse than none. Update it in the same commit.

## Done means done

Before you call a task finished:

- It runs. The tests pass. The linter and type checker are clean. You ran them.
  You did not assume.
- New behaviour has a test. The fixed bug has a test.
- No debug print, no scratch file, no leftover branch of dead code.
- You read the whole diff yourself. Anything you cannot defend comes out.
- A step failed or you skipped it? Say so plainly. Never report done over a
  failing test.
