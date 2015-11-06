#!/bin/sh
set -eu
nix-shell -p leksah --command "leksah $*"