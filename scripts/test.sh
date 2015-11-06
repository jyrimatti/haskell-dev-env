#!/bin/sh
set -eu
cd /tmp/ && cabal.sh init -n
firefox.sh
emacs.sh
sublime.sh
atom.sh
hoogle.sh 'Maybe a -> a'
