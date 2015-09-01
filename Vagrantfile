
### Customizable Haskell development environment with IDEs in one VagrantFile
### #vagrant #virtualbox #nixos #nix #haskell #ghcjs


# 1) put this file to the directory you wish to mount as /vagrant
# 2) install an XServer (if you want to run GUI apps)
# 3) install Vagrant
# 4) > vagrant plugin install vagrant-nixos
# 5) > vagrant up
# 6) > vagrant ssh    # or vagrant ssh -- -Y if you want to run GUI apps)

# This NixOS uses NixPKGS GIT repo for all the latest and greatest stuff.
# A specific revision is checked out to ensure an eternally consistent environment.
# You can upgrade if you wish by checking out a more recent revision:
# > cd /home/vagrant/nixpkgs && git pull origin master

# Pretty much nothing at all is installed in the root shell.
# You can start a suitable nix-shell the usual way, or use these predefined commands:

# Run a build-independent cabal command, e.g. init a new cabal project:
# > cabal.sh init

# test X11 is working:
# > nix-shell -p xeyes --command 'xeyes'

# Start Firefox:
# > firefox.sh

# Start a cabal project shell for a cabal-project in the current dir:
# > shell.sh

# The following scripts are intended to be run within a project-specific shell (started for example via shell.sh):

# Hoogle:
# > hoogle.sh 'Maybe a -> a'

# Continuously-compile with GHC (without cabal) and restart app whenever a source file is changed:
# > cc.sh

# Start Sublime Text:
# > sublime.sh

# Start Atom.IO:
# > atom.sh

# Start Emacs:
# > emacs.sh

# Start Leksah:
# TODO

# Start Emacs:
# TODO

# Start Vim:
# TODO



Vagrant.configure("2") do |config|

    # whatever 64-bit nixos box 
    config.vm.box = "larryweya/nixos-14.12_64"

    config.vm.provider 'virtualbox' do |v|
      v.memory = 2048
      v.cpus = 2
      # v.gui = true   # enable this if you prefer the GUI
    end
  
    # open a port for browsing web apps from the host machine
    #config.vm.network "forwarded_port", guest: 80, host: 8181

    # forward X11 to run GUI apps
    config.ssh.forward_x11 = true

    # nixos-stuff
    config.vm.provision :nixos, :expression => {
        environment: {
            systemPackages: [:'python34Packages.pygments']
        },
        programs: {
            # running GUI apps through SSH seems to need this...
            ssh: {
                setXAuthLocation: true
            },
            zsh: {
                enable: true
            }
        },
        users: {
            defaultUserShell: "/run/current-system/sw/bin/zsh"
        },
        security: {
            # either NixOS in general or just the used box seems to need these...
            sudo: {
                enable: true,
                wheelNeedsPassword: false
            }
        },
        services: {
            # TODO: make work for GHCJS
            httpd: {
                adminAddr: "vagrant@localhost",
                enable: true,
                documentRoot: "/home/vagrant/.cabal/bin"
            }
        },
        swapDevices: [{
          device: '/swap',
          size: 2048
        }],
        nix: {
            # Use at most one cache due to a GHC bug:
            #  http://hydra.nixos.org/build/24422016/download/1/nixpkgs/manual.html#how-to-recover-from-ghcs-infamous-non-deterministic-library-id-bug
            #  https://ghc.haskell.org/trac/ghc/ticket/4012
            # Remove caches altogether if still fails.
            binaryCaches: [ "https://hydra.nixos.org" ],
            trustedBinaryCaches: [ "https://hydra.nixos.org" ]
        }
    }

    # the used box does not work with vagrant-nixos-plugin out-of-the-box, thus these hacks
    config.vm.provision :shell,
        inline: "test -e /etc/nixos/configuration.orig.nix || (mv /etc/nixos/configuration.nix /etc/nixos/configuration.orig.nix && echo '{ config, pkgs, ... }: { imports = [ ./configuration.orig.nix ./vagrant.nix ];}' > /etc/nixos/configuration.nix)"

    # "install" NixPkgs GIT repo
    config.vm.provision :shell,
        inline: $initpkgs,
        privileged: false

    # update nixos
    config.vm.provision :shell,
        inline: 'sudo nixos-rebuild switch'

    # install oh-my-zsh
    config.vm.provision :shell,
        inline: $ohmyzsh,
        privileged: false

    # init config.nix to allow some packages
    config.vm.provision :shell,
        inline: "test -e /home/vagrant/.nixpkgs || (mkdir -p /home/vagrant/.nixpkgs && echo '{ allowUnfree = true; allowBroken = true; }' > /home/vagrant/.nixpkgs/config.nix)",
        privileged: false

    # generic shell.nix for invoking different default.nix-files
    config.vm.provision :shell,
        inline: $shellnix,
        privileged: false

    # initialize a directory for scripts
    config.vm.provision :shell,
        inline: "test -e /home/vagrant/bin || (mkdir /home/vagrant/bin & export PATH=$PATH:/home/vagrant/bin/)",
        privileged: false

    # script for running some cabal commands "without cabal".
    config.vm.provision :shell,
        inline: $cabal,
        privileged: false

    # script for starting a new shell with cabal-dependencies from a cabal project in the current directory
    config.vm.provision :shell,
        inline: $shell,
        privileged: false

    # script for querying hoogle
    config.vm.provision :shell,
        inline: $hoogle,
        privileged: false

    # script for continuous-compilation with GHC
    config.vm.provision :shell,
        inline: $cc,
        privileged: false

    # script for running Sublime Text with Haskell development tools
    config.vm.provision :shell,
        inline: $sublime,
        privileged: false

    # script for running Atom.IO with Haskell development tools
    config.vm.provision :shell,
        inline: $atom,
        privileged: false

    # script for running Emacs editor
    config.vm.provision :shell,
        inline: $emacs,
        privileged: false

    # script for running Leksah editor
    config.vm.provision :shell,
        inline: $leksah,
        privileged: false

    # script for running Firefox browser
    config.vm.provision :shell,
        inline: $firefox,
        privileged: false

    # script for testing
    config.vm.provision :shell,
        inline: $test,
        privileged: false

    # permissions for Apache to see GHCJS apps, and for Cabal to install GHCJS apps.
    config.vm.provision :shell,
        inline: 'chmod o+x /home/vagrant && (test -e /home/vagrant/.cabal || mkdir /home/vagrant/.cabal) && chown vagrant:vagrant /home/vagrant/.cabal && (test -e /home/vagrant/.cabal/bin || mkdir /home/vagrant/.cabal/bin) && chown vagrant:vagrant /home/vagrant/.cabal/bin'

end



$initpkgs = <<SCRIPT
test -e /home/vagrant/nixpkgs || (
  git clone https://github.com/NixOS/nixpkgs /home/vagrant/nixpkgs &&
  # "install" cloned git repo
  ln -s /home/vagrant/nixpkgs /home/vagrant/.nix-defexpr/nixpkgs &&
  # remove old nixos channels
  rm -rf /home/vagrant/.nix-defexpr/channels &&
  rm -rf /home/vagrant/.nix-defexpr/channels_root &&
  echo 'export NIX_PATH=nixpkgs=/home/vagrant/nixpkgs:$NIX_PATH' >> /home/vagrant/.profile
)
cd /home/vagrant/nixpkgs
git fetch
# NixPkgs revision to use. Feel free to update, but note that in master branch stuff seems to break a lot...
git checkout '75cf3a27670ae0213aa12feb32ed563a4dbf3a8c'
SCRIPT



$ohmyzsh = <<SCRIPT
test -e /home/vagrant/.zshrc || (
    (zsh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || true) &&
    echo 'source /home/vagrant/.profile' >> /home/vagrant/.zshrc &&
    echo 'PROMPT="λ $PROMPT"' >> /home/vagrant/.zshrc &&
    echo 'alias cat=colorize' >> /home/vagrant/.zshrc
)
sed -i "s/plugins=\(git\)/plugins=(git mercurial colorize cabal)/g" /home/vagrant/.zshrc
SCRIPT



$shellnix = <<SCRIPT
echo '{app, compiler ? null, overrides ? (self: {})}:'                                                                  > /home/vagrant/shell.nix
echo 'with (import <nixpkgs> {}).pkgs;'                                                                                >> /home/vagrant/shell.nix
echo 'let hsp = if compiler == null then pkgs.haskellPackages else pkgs.haskell.packages.${compiler};'                 >> /home/vagrant/shell.nix
echo '    hsPkgs = hsp.override { overrides = self: super: overrides self; };'                                         >> /home/vagrant/shell.nix
echo '    appPackage = with hsPkgs; callPackage app {};'                                                               >> /home/vagrant/shell.nix
echo 'in pkgs.lib.overrideDerivation appPackage.env (old: {buildInputs = old.buildInputs ++ [pkgs.haskellPackages.cabal-install hsPkgs.ghc];})' >> /home/vagrant/shell.nix
SCRIPT



# TODO: https://github.com/NixOS/nix/issues/498
# zsh in nix-shell does not work yet, so need to use --command with a twist
$shell = <<SCRIPT
echo '#!/bin/sh'                                                                                                        > /home/vagrant/bin/shell.sh
echo 'set -u'                                                                                                          >> /home/vagrant/bin/shell.sh
echo "def='(s: {})'"                                                                                                   >> /home/vagrant/bin/shell.sh
echo 'overrides="${1:-$def}"'                                                                                          >> /home/vagrant/bin/shell.sh
echo 'app=$(if [ -f "$PWD/shell.nix" ]; then echo "$PWD/shell.nix"; else echo "$PWD/default.nix"; fi;)'                >> /home/vagrant/bin/shell.sh
echo 'nix-shell -p haskellPackages.cabal2nix --command "cabal2nix . > default.nix"'                                    >> /home/vagrant/bin/shell.sh
echo 'foo=$(grep ghcjs $app)'                                                                                          >> /home/vagrant/bin/shell.sh
echo 'if [ $? -eq 0 ]; then'                                                                                           >> /home/vagrant/bin/shell.sh
echo '  nix-shell /home/vagrant/shell.nix --arg app $app --arg overrides "$overrides" --command "exec zsh; return" --argstr compiler ghcjs'         >> /home/vagrant/bin/shell.sh
echo 'else'                                                                                                            >> /home/vagrant/bin/shell.sh
echo '  bar=$(grep haste-compiler $app)'                                                                               >> /home/vagrant/bin/shell.sh
echo '  if [ $? -eq 0 ]; then'                                                                                         >> /home/vagrant/bin/shell.sh
echo '    nix-shell /home/vagrant/shell.nix --arg app $app --arg overrides "$overrides" --command "exec zsh; return" --argstr compiler ghc784'      >> /home/vagrant/bin/shell.sh
echo '  else'                                                                                                          >> /home/vagrant/bin/shell.sh
echo '    nix-shell /home/vagrant/shell.nix --arg app $app --arg overrides "$overrides" --command "exec zsh; return"'                               >> /home/vagrant/bin/shell.sh
echo '  fi'                                                                                                            >> /home/vagrant/bin/shell.sh
echo 'fi'                                                                                                              >> /home/vagrant/bin/shell.sh
chmod u+x /home/vagrant/bin/shell.sh 
SCRIPT



$cabal = <<SCRIPT
echo '#!/bin/sh'                                                                                                        > /home/vagrant/bin/cabal.sh
echo 'set -eu'                                                                                                         >> /home/vagrant/bin/cabal.sh
echo 'nix-shell -p haskellPackages.cabal-install -p haskellPackages.ghc --command "cabal $*"'                          >> /home/vagrant/bin/cabal.sh
chmod u+x /home/vagrant/bin/cabal.sh
SCRIPT



$hoogle = <<SCRIPT
echo '#!/bin/sh'                                                                                                        > /home/vagrant/bin/hoogle.sh
echo 'set -eu'                                                                                                         >> /home/vagrant/bin/hoogle.sh
echo 'cd /home/vagrant/hoogledb'                                                                                       >> /home/vagrant/bin/hoogle.sh
echo 'nix-shell -p haskellPackages.hoogle --command "hoogle data all -d /home/vagrant/hoogledb && hoogle $*"'          >> /home/vagrant/bin/hoogle.sh
chmod u+x /home/vagrant/bin/hoogle.sh 
SCRIPT



$sublime = <<SCRIPT
echo '#!/bin/sh'                                                                                                           > /home/vagrant/bin/sublime.sh
echo 'set -eu'                                                                                                            >> /home/vagrant/bin/sublime.sh

echo 'nix-shell -p haskellPackages.stylish-haskell -p haskellPackages.hsdev -p sublime3 --command "sublime $*"' >> /home/vagrant/bin/sublime.sh

chmod u+x /home/vagrant/bin/sublime.sh

test -e /home/vagrant/.config/sublime-text-3 || (
  mkdir -p "/home/vagrant/.config/sublime-text-3/Installed Packages" &&
  curl https://packagecontrol.io/Package%20Control.sublime-package > "/home/vagrant/.config/sublime-text-3/Installed Packages/Package Control.sublime-package"
)
test -e /home/vagrant/.config/sublime-text-3/Packages || (
  mkdir -p /home/vagrant/.config/sublime-text-3/Packages/
)
test -e /home/vagrant/.config/sublime-text-3/Packages/SublimeHaskell || (
  git clone https://github.com/SublimeHaskell/SublimeHaskell.git /home/vagrant/.config/sublime-text-3/Packages/SublimeHaskell &&
  (test -e /home/vagrant/.config/sublime-text-3/Packages/User || mkdir /home/vagrant/.config/sublime-text-3/Packages/User) &&
  echo '{ "enable_hdevtools": false, "enable_hsdev": true }' > /home/vagrant/.config/sublime-text-3/Packages/User/SublimeHaskell.sublime-settings
)
cd /home/vagrant/.config/sublime-text-3/Packages/SublimeHaskell
git pull
git checkout hsdev
git checkout 'c1f92945bfbc3b52c719d4cb8f26c1eb4fd5b27b'
SCRIPT



$atom = <<SCRIPT
echo '#!/bin/sh'                                                                                                        > /home/vagrant/bin/atom.sh
echo 'set -eu'                                                                                                         >> /home/vagrant/bin/atom.sh
echo 'nix-shell -p atom --command "apm install language-haskell haskell-ghc-mod ide-haskell autocomplete-haskell"'     >> /home/vagrant/bin/atom.sh

echo 'nix-shell -p "pkgs.haskellPackages.ghcWithPackages (pkgs: [pkgs.ghc-mod])" -p haskellPackages.cabal-install -p haskellPackages.hlint -p haskellPackages.stylish-haskell -p atom --command "atom $*"' >> /home/vagrant/bin/atom.sh

chmod u+x /home/vagrant/bin/atom.sh 
SCRIPT



$emacs = <<SCRIPT
test -e /home/vagrant/.spacemacs || (
  git clone --recursive https://github.com/syl20bnr/spacemacs /home/vagrant/.emacs.d && 
  cp /home/vagrant/.emacs.d/core/templates/.spacemacs.template /home/vagrant/.spacemacs &&
  sed -i "s/emacs-lisp/emacs-lisp (haskell :variables haskell-enable-ghci-ng-support t)/g" /home/vagrant/.spacemacs &&
  sed -i "s/dotspacemacs-excluded-packages '()/dotspacemacs-excluded-packages '(exec-path-from-shell)/g" /home/vagrant/.spacemacs
)
cd /home/vagrant/.emacs.d
git pull
echo '#!/bin/sh'                               > /home/vagrant/bin/emacs.sh
echo 'set -eu'                                >> /home/vagrant/bin/emacs.sh
echo 'nix-shell -p "pkgs.haskellPackages.ghcWithPackages (pkgs: [pkgs.ghc-mod])" -p haskellPackages.cabal-install -p haskellPackages.hlint -p haskellPackages.stylish-haskell -p haskellPackages.hasktags -p emacs --command "emacs $*"'   >> /home/vagrant/bin/emacs.sh
chmod u+x /home/vagrant/bin/emacs.sh 
SCRIPT



$leksah = <<SCRIPT
echo '#!/bin/sh'                                > /home/vagrant/bin/leksah.sh
echo 'set -eu'                                  >> /home/vagrant/bin/leksah.sh
echo 'nix-shell -p leksah --command "leksah $*"'   >> /home/vagrant/bin/leksah.sh
chmod u+x /home/vagrant/bin/leksah.sh 
SCRIPT



$firefox = <<SCRIPT
echo '#!/bin/sh'                                     > /home/vagrant/bin/firefox.sh
echo 'set -eu'                                      >> /home/vagrant/bin/firefox.sh
echo 'nix-shell -p firefox --command "firefox $*"'     >> /home/vagrant/bin/firefox.sh
chmod u+x /home/vagrant/bin/firefox.sh 
SCRIPT



$cc = <<SCRIPT
echo '#!/bin/sh'                                                                                                        > /home/vagrant/bin/cc.sh
echo 'set -eu'                                                                                                         >> /home/vagrant/bin/cc.sh
echo 'PID=$$'                                                                                                          >> /home/vagrant/bin/cc.sh
echo 'while true; do'                                                                                                  >> /home/vagrant/bin/cc.sh
echo '  test -e build || mkdir build'                                                                                  >> /home/vagrant/bin/cc.sh
echo '  time ghc --make -outputdir build -o build/prog -isrc src/Main.hs $@'                                           >> /home/vagrant/bin/cc.sh
echo '  build/prog &'                                                                                                  >> /home/vagrant/bin/cc.sh
echo '  nix-shell -p inotifyTools --command "inotifywait -e modify -e move -e create -e delete src || true"'           >> /home/vagrant/bin/cc.sh
echo '  pkill -P $PID || true'                                                                                         >> /home/vagrant/bin/cc.sh
echo 'done'                                                                                                            >> /home/vagrant/bin/cc.sh
chmod u+x /home/vagrant/bin/cc.sh 
SCRIPT



$test = <<SCRIPT
echo '#!/bin/sh'                     > /home/vagrant/bin/test.sh
echo 'set -eu'                      >> /home/vagrant/bin/test.sh
echo 'cd /tmp/ && cabal.sh init -n' >> /home/vagrant/bin/test.sh
echo 'firefox.sh'                   >> /home/vagrant/bin/test.sh
echo 'emacs.sh'                     >> /home/vagrant/bin/test.sh
echo 'sublime.sh'                   >> /home/vagrant/bin/test.sh
echo 'atom.sh'                      >> /home/vagrant/bin/test.sh
echo "hoogle.sh 'Maybe a -> a'"     >> /home/vagrant/bin/test.sh
chmod u+x /home/vagrant/bin/test.sh 
SCRIPT
