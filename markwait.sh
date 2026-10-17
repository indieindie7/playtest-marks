#!/bin/sh
# Game-aware mark watcher for an AI coding agent (run it as a background shell task, no time limit).
# Sleeps while the game is closed; while it runs, watches the marks file.
# Exits on the first new mark, printing "MARK <json>" (that exit is what wakes the agent);
# the agent handles the mark and starts this again. Game start/close only go to the log.
#   MARKS_FILE    marks file the game appends one JSON line to per mark (default ./marks/marks.jsonl)
#   GAME_PROCESS  regex for the game's process image name (default "game\.exe")
f="${MARKS_FILE:-./marks/marks.jsonl}"
proc="${GAME_PROCESS:-game\.exe}"
log="${TEMP:-/tmp}/markwait.log"
mkdir -p "$(dirname "$f")"; touch "$f"
if command -v tasklist >/dev/null 2>&1; then
  running() { tasklist //NH //FO CSV 2>/dev/null | grep -qi -E "\"($proc)\""; }
else
  running() { pgrep -f -i "$proc" >/dev/null 2>&1; }
fi
count() { wc -l < "$f" | tr -d ' '; }
seen=$(count)
while :; do
  until running; do sleep 2; done
  echo "$(date +%H:%M:%S) game started, watching marks" >> "$log"
  while running; do
    n=$(count)
    if [ "$n" -gt "$seen" ]; then
      tail -n $((n - seen)) "$f" | while IFS= read -r line; do echo "MARK $line"; done
      exit 0
    fi
    [ "$n" -lt "$seen" ] && seen=$n   # file was cleared
    sleep 1
  done
  echo "$(date +%H:%M:%S) game closed, watcher idle" >> "$log"
  # A mark typed in the last second before closing still counts.
  n=$(count); if [ "$n" -gt "$seen" ]; then tail -n $((n - seen)) "$f" | sed 's/^/MARK /'; exit 0; fi
done
