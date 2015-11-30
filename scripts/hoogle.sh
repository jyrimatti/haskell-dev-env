#!/bin/sh
set -eu
nix-shell -p haskellPackages.hoogle --command "hoogle data -d $NIX_SHELL_ROOT/hoogledb && hoogle -d $NIX_SHELL_ROOT/hoogledb '$*'"

