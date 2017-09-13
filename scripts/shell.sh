#!/bin/sh
set -u
def='(s: {})'
overrides="${1:-$def}"
app=$(if [ -f "$PWD/shell.nix" ]; then echo "$PWD/shell.nix"; else echo "$PWD/default.nix"; fi;)
nix-shell -p haskellPackages.cabal2nix --command "cabal2nix . > default.nix"
dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
foo=$(grep ghcjs $app)
if [ $? -eq 0 ]; then
  echo "Using GHCJS"
  command="nix-shell $dir/shell.nix --arg app $app --arg overrides \"$overrides\" --command \"PATH_SUFFIX=\$PATH PROMPT_PREFIX='%{\\\$fg_bold[red]%}λ' NIX_SHELL_ROOT=\$PWD exec zsh; return\" --argstr compiler ghcjs"
  echo "Running: $command"
  bash -c "$command"
else
  bar=$(grep haste-compiler $app)
  if [ $? -eq 0 ]; then
    echo "Using Haste" 
    nix-shell $dir/shell.nix --arg app $app --arg overrides "$overrides" --command "PATH_SUFFIX=\$PATH PROMPT_PREFIX='%{\\\$fg_bold[red]%}λ' NIX_SHELL_ROOT=\$PWD exec zsh; return" --argstr compiler ghc784
  else
    nix-shell $dir/shell.nix --arg app $app --arg overrides "$overrides" --command "PATH_SUFFIX=\$PATH PROMPT_PREFIX='%{\\\$fg_bold[red]%}λ'  NIX_SHELL_ROOT=\$PWD exec zsh; return"
  fi
fi
