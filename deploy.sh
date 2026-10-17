#!/bin/sh
# Rebuild deploy for a game the player keeps open (Windows, Git Bash): waits while a mark is being
# written (the game holds a lock file while its mark box is open), closes the game, copies the new
# build over the play copy and starts it again.
#   BUILD_EXE   freshly built exe            (default ./target/release/game.exe)
#   PLAY_DIR    folder the player runs from  (default ./dist/game)
#   PLAY_EXE    exe name inside PLAY_DIR     (default game.exe)
#   LOCK_FILE   lock the game writes while a mark is open (default $PLAY_DIR/marks/typing.lock)
build="${BUILD_EXE:-./target/release/game.exe}"
dir="${PLAY_DIR:-./dist/game}"
exe="${PLAY_EXE:-game.exe}"
lock="${LOCK_FILE:-$dir/marks/typing.lock}"
name="${exe%.exe}"
n=0
while [ -f "$lock" ]; do
  tasklist //FI "IMAGENAME eq $exe" | grep -qi "$name" || { echo "stale lock removed (game not running)"; rm -f "$lock"; break; }
  [ $n = 0 ] && echo "waiting: mark being written"; n=1; sleep 2
done
win() { cygpath -w "$1" 2>/dev/null || echo "$1"; }
powershell -NoProfile -Command "Stop-Process -Name '$name' -Force -ErrorAction SilentlyContinue; Start-Sleep 1; Copy-Item '$(win "$build")' '$(win "$dir/$exe")' -Force; Start-Process '$(win "$dir/$exe")' -WorkingDirectory '$(win "$dir")'"
echo deployed
