# playtest-marks

Three small shell scripts for a playtest loop where you play your game while an AI coding agent (or any tool) fixes what you point at.

The game has a "mark" key. Pressing it opens a text box; you type a note ("this jump is too short") and the game appends one JSON line to `marks.jsonl`. A watcher wakes the agent with that line, the agent changes the code, rebuilds, and `deploy.sh` swaps the new build in, without closing the game while you are still typing.

| Script | What it does |
|---|---|
| `markwait.sh` | Sleeps while the game is closed. While it runs, exits on the first new mark and prints `MARK <json>`. Run it as a background task; its exit is the wake-up. Start it again after each mark. |
| `markwatch.sh` | `tail -F` version: streams `MARK <json>` lines forever, for tools that read output line by line. |
| `deploy.sh` | Waits while the mark box is open (the game holds a lock file), closes the game, copies the new exe over the play copy and starts it again. Windows / Git Bash. |

## Settings (environment variables)

| Variable | Default | Used by |
|---|---|---|
| `MARKS_FILE` | `./marks/marks.jsonl` | markwait, markwatch |
| `GAME_PROCESS` | `game\.exe` (regex on the process name) | markwait |
| `BUILD_EXE` | `./target/release/game.exe` | deploy |
| `PLAY_DIR` | `./dist/game` | deploy |
| `PLAY_EXE` | `game.exe` | deploy |
| `LOCK_FILE` | `$PLAY_DIR/marks/typing.lock` | deploy |

## The mark format

One JSON object per line. Only the note is needed; the rest is whatever helps the agent find the spot. Fields we use:

| Field | Meaning |
|---|---|
| `n` | mark number |
| `note` | what the player typed |
| `room`, `room_name` | where the player was |
| `player_x` | player position |
| `x` | world position the mark points at |
| `selected` | the object picked in the game's editor, if any |
| `dropped` | file dragged onto the game window, if any |
| `shot` | path of a screenshot saved with the mark |

```json
{"n": 12, "note": "this jump is too short", "room": 3, "room_name": "bridge", "player_x": 41.5, "shot": "marks/shot_12.png"}
```

The game side (mark key, text box, lock file while typing, screenshot) is a few dozen lines in any engine.

## Licence

MIT.
