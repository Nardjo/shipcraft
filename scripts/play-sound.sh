#!/bin/bash

# Play sound with error handling - completely silent approach
SOUND_FILE="/Users/jordanbastin/.claude/song/finish.mp3"

# Try original MP3 first, then fallback to system sound, then give up silently
/usr/bin/afplay "$SOUND_FILE" 2>/dev/null || \
/usr/bin/afplay /System/Library/Sounds/Ping.aiff 2>/dev/null || \
/usr/bin/say "Done" 2>/dev/null || \
true

exit 0
