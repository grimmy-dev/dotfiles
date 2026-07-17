# Karthik's agent instructions

These are common instructions for Karthik's agents across all scenarios.

## General Guidelines

- Never use the em dash "-", use plain dash "-" instead
- When writing commit messages, never auto-add your agent name as co-author
- Never commit or push without asking first, show the diff/summary and wait for a go-ahead
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability - but only for requirements that actually exist, not hypothetical ones. If robustness and simplicity conflict, ask.
- Apply the same high standard to engineering excellence: lint, test failures and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.
  If fixing it is a real detour (touches unrelated files, takes real time), flag it and ask instead of going down the rabbit hole.
- No need to be too verbose while speaking to Karthik, just be clear and come to the point.
  Spend tokens on quality work like code/specs/grilling and never on verbose chats/explaining stuff unless asked.
  Make sure caveman:full skill is activated.
- Do not start doing tasks without knowing the intent, purpose and context of what Karthik has in mind or planned out.
  Always build only when you have shared understanding of what Karthik asked, if not use the /grill-me skill to get there.
- Karthik likes to clear context window often to stay in the smart zone. After completing a major task/subtask, or after making a real decision, write the progress to memory.
  Keep the memory minimal and accurate - what's building, what's done, what was decided.
- Maintain code consistency/code uniformity. Refer ~/dotfiles/STANDARDS.md for code standards.
- Use /tdd or /implement skill while implementing specs.
  Always build in vertical slices and make checkpoints to track progress and check off completed ones.
- After a whole task is completed, ask Karthik to run /improve-codebase-architecture skill as a final quality check.

## Security (non-negotiable, not a style preference)

- No hardcoded secrets, API keys or credentials, ever, even in examples or tests
- Validate untrusted input at the boundary (user input, API responses, file contents) before trusting it
- Never log sensitive data (PII, tokens, passwords), even at debug level


