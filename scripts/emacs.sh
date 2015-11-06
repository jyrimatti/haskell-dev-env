#!/bin/sh
set -eu
nix-shell -p "pkgs.haskellPackages.ghcWithPackages (pkgs: [pkgs.ghc-mod])" -p haskellPackages.cabal-install -p haskellPackages.hlint -p haskellPackages.stylish-haskell -p haskellPackages.hasktags -p emacs --command "emacs $*"
