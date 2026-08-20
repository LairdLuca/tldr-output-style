# TL;DR Output Style

A Claude Code plugin that closes long replies with a one-glance summary, so you
get the point without scanning the whole answer for it.

```
...several paragraphs of explanation...

---
**TL;DR** - uploads fail above 2 MB because the buffer is hardcoded at 2048 KB,
one-line fix at Uploader.cs:88.
```

## What it does

When Claude's final reply of a turn contains **two or more paragraphs of prose**,
it ends with a short summary carrying the conclusion.

The rules, in short:

- **Prose only.** Bullet lists, code blocks, command output, tables and diffs do
  not count as paragraphs. A reply made of bullets, or of one paragraph plus a
  code block, is already scannable and gets nothing. Keeping the trigger narrow
  ties the summary to the case it actually solves: walls of text where the
  conclusion sits buried in the middle.
- **Final reply only,** not the short narration lines between tool calls. Those
  are progress, not conclusions.
- **Adaptive length.** One sentence by default; two or three bullets only when
  the reply genuinely covers separate items, such as several files touched or
  several test outcomes.
- **Conclusion, not subject.** "I looked into the upload flow" is a table of
  contents, not a TL;DR. A reader who trusts you should be able to stop at the
  summary and act on it.
- **No new information.** The summary compresses what the reply already says. If
  a caveat only fits in the TL;DR, it was missing from the reply itself.
- Written in the same language as the rest of the reply.

## Install

```
/plugin marketplace add LairdLuca/tldr-output-style
/plugin install tldr-output-style@tldr-output-style
```

Then restart your session: `SessionStart` hooks only run at startup.

To turn it off without uninstalling, run `/plugin` and disable it from the list.

## Cost

Like any `SessionStart` hook, this one has a fixed token cost at the start of
every session (roughly 650 tokens), plus the cost of the TL;DR itself on every
long reply. If you run a lot of short sessions, that adds up. It is worth
knowing before you install it, not after.

## Customising

The behaviour lives in
[`plugins/tldr-output-style/hooks-handlers/instructions.md`](plugins/tldr-output-style/hooks-handlers/instructions.md)
as plain markdown. `session-start.sh` reads that file and JSON-escapes it at
runtime, so changing the rules means editing markdown, not rewriting an escaped
JSON string by hand.

Things you might want to change: the two-paragraph threshold, the `**TL;DR**`
label, the position (move it above the reply instead of below), or the language
rule. Edit the file, restart the session, done.

## How it works

Claude Code runs the plugin's `SessionStart` hook at the beginning of every
session. The hook prints a JSON object whose `additionalContext` field is
appended to Claude's system context:

```
hooks/hooks.json            declares the SessionStart hook
hooks-handlers/
  session-start.sh          reads instructions.md, escapes it, prints the JSON
  instructions.md           the actual behaviour, in plain markdown
```

This is deliberately not a Skill. Skills load when the model judges them
relevant to the task at hand, which is the right design for a capability but the
wrong one for a formatting rule that has to apply to every reply: the trigger
would fire unevenly and you would get a TL;DR on some answers and not others.
Hook-injected context is unconditional, which is exactly what an output style
needs. The trade-off is the fixed token cost noted above.

The script fails open. If `instructions.md` is missing or unreadable it exits
quietly with no output, rather than printing truncated JSON that the hook runner
would have to reject on every startup.

## Credits

The architecture is borrowed from Anthropic's
[`explanatory-output-style`](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/explanatory-output-style)
plugin, which recreates the deprecated Explanatory output style the same way.
The instructions and the escaping script here are original.

## License

MIT. See [LICENSE](LICENSE).
