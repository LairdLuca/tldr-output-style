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
# round would re-escape the backslashes this very step inserts. Tabs come after
# both, for the same reason -- the backslash they introduce must be the last one
# added. Every control character still standing after that, the CR of a Windows
# line ending included, is illegal inside a JSON string and means nothing in
# markdown, so it is dropped rather than escaped. Then the newlines are folded
# into a literal \n.
#
# The tab is matched through a variable holding a real one, and the leftovers
# through [[:cntrl:]]: both are POSIX, whereas \t and \r inside a sed expression
# are a GNU extension that other seds are free to read as the bare letter.
tab=$'\t'
escaped=$(sed \
  -e 's/\\/\\\\/g' \
  -e 's/"/\\"/g' \
  -e "s/$tab/\\\\t/g" \
  -e 's/[[:cntrl:]]//g' \
  "$INSTRUCTIONS" | awk '{ printf "%s\\n", $0 }')

if [ -z "$escaped" ]; then
  exit 0
fi

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$escaped"

exit 0
