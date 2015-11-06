#!/bin/sh
set -eu
nix-shell -p haskellPackages.stylish-haskell -p haskellPackages.hsdev -p sublime3 --command "sublime $*"
