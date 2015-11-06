#!/bin/sh
set -eu
nix-shell -p atom --command "apm install language-haskell haskell-ghc-mod ide-haskell autocomplete-haskell"
nix-shell -p "pkgs.haskellPackages.ghcWithPackages (pkgs: [pkgs.ghc-mod])" -p haskellPackages.cabal-install -p haskellPackages.hlint -p haskellPackages.stylish-haskell -p atom --command "atom $*"
