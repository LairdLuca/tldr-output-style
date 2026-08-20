#!/usr/bin/env bash

# Injects the TL;DR output style instructions as SessionStart additionalContext.
# The instructions live in instructions.md next to this script so they can be
# edited as plain markdown instead of as an escaped JSON string.

set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTRUCTIONS="$DIR/instructions.md"

# Fail open: a missing or unreadable file means no extra context, never broken
# JSON on stdout, which the hook runner would have to reject.
if [ ! -r "$INSTRUCTIONS" ]; then
  exit 0
fi

# JSON-escape the file. Backslashes first, then quotes: doing it the other way
# round would re-escape the backslashes this very step inserts. Then drop the CR
# of any Windows line ending, and fold the newlines into a literal \n.
escaped=$(sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\r$//' "$INSTRUCTIONS" \
  | awk '{ printf "%s\\n", $0 }')

if [ -z "$escaped" ]; then
  exit 0
fi

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$escaped"

exit 0
