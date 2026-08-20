# tldr-output-style

Closes every Claude Code reply of two or more prose paragraphs with a short
TL;DR carrying the conclusion.

```
...several paragraphs of explanation...

---
**TL;DR** - uploads fail above 2 MB because the buffer is hardcoded at 2048 KB,
one-line fix at Uploader.cs:88.
```

## Install

```
/plugin marketplace add LairdLuca/tldr-output-style
/plugin install tldr-output-style@tldr-output-style
```

Restart the session afterwards: `SessionStart` hooks only run at startup.

## Files

| File | Role |
|---|---|
| `hooks/hooks.json` | declares the `SessionStart` hook |
| `hooks-handlers/session-start.sh` | reads the instructions, JSON-escapes them, prints the hook payload |
| `hooks-handlers/instructions.md` | the behaviour itself, in plain markdown |

To change what the TL;DR looks like or when it appears, edit
[`hooks-handlers/instructions.md`](hooks-handlers/instructions.md) and restart
the session. There is no escaped JSON string to maintain by hand.

Full documentation, rules and rationale:
[repository README](../../README.md).
