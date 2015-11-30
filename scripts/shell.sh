#!/bin/sh
set -u
def='(s: {})'
overrides="${1:-$def}"
app=$(if [ -f "$PWD/shell.nix" ]; then echo "$PWD/shell.nix"; else echo "$PWD/default.nix"; fi;)
nix-shell -p haskellPackages.cabal2nix --command "cabal2nix . > default.nix"
foo=$(grep ghcjs $app)
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ $? -eq 0 ]; then
  nix-shell $dir/shell.nix --arg app $app --arg overrides "$overrides" --command "PATH_SUFFIX=\$PATH PROMPT_PREFIX='%{\$fg_bold[red]%}' exec zsh; return" --argstr compiler ghcjs
else
  bar=$(grep haste-compiler $app)
  if [ $? -eq 0 ]; then
    nix-shell $dir/shell.nix --arg app $app --arg overrides "$overrides" --command "PATH_SUFFIX=\$PATH PROMPT_PREFIX='%{\$fg_bold[red]%}' exec zsh; return" --argstr compiler ghc784
  else
    nix-shell $dir/shell.nix --arg app $app --arg overrides "$overrides" --command "PATH_SUFFIX=\$PATH PROMPT_PREFIX='%{\$fg_bold[red]%}' exec zsh; return"
  fi
fi