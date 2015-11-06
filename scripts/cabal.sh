#!/bin/sh
set -eu
nix-shell -p haskellPackages.cabal-install -p haskellPackages.ghc --command "cabal $*"
