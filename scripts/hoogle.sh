#!/bin/sh
set -eu
cd /home/vagrant/hoogledb
nix-shell -p haskellPackages.hoogle --command "hoogle data all -d /home/vagrant/hoogledb && hoogle $*"
