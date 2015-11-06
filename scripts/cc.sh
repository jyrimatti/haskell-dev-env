#!/bin/sh
set -eu
PID=$$
while true; do
  test -e build || mkdir build
  time ghc --make -outputdir build -o build/prog -isrc src/Main.hs $@
  build/prog &
  nix-shell -p inotifyTools --command "inotifywait -e modify -e move -e create -e delete src || true"
  pkill -P $PID || true
done
