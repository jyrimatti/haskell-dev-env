
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

    config.vm.synced_folder "scripts/", "/home/vagrant/bin/"

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

    # initialize a directory for scripts
    config.vm.provision :shell,
        inline: "test -e /home/vagrant/bin || (mkdir /home/vagrant/bin & export PATH=$PATH:/home/vagrant/bin/)",
        privileged: false

    # script for running Sublime Text with Haskell development tools
    config.vm.provision :shell,
        inline: $sublime,
        privileged: false

    # script for running Emacs editor
    config.vm.provision :shell,
        inline: $emacs,
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
  rm -rf /home/vagrant/.nix-defexpr/channels_root
)
echo 'export NIX_PATH=nixpkgs=/home/vagrant/nixpkgs:$NIX_PATH' > /home/vagrant/.profile
cd /home/vagrant/nixpkgs
git fetch
# NixPkgs revision to use. Feel free to update, but note that in master branch stuff seems to break a lot...
git checkout 'f16533449269bf798cd49eac41ba876b71eeddc0'
SCRIPT



$ohmyzsh = <<SCRIPT
test -e /home/vagrant/.zshrc || (
    (zsh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || true) &&
    echo 'source /home/vagrant/.profile' >> /home/vagrant/.zshrc
)
echo 'PROMPT="${PROMPT_PREFIX}λ $PROMPT"' >> /home/vagrant/.profile
echo 'alias cat=colorize'                 >> /home/vagrant/.profile
echo 'PATH="$PATH:$PATH_SUFFIX"'          >> /home/vagrant/.profile
sed -i "s/plugins=\(git\)/plugins=(git mercurial colorize cabal)/g" /home/vagrant/.zshrc
SCRIPT



$sublime = <<SCRIPT
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


$emacs = <<SCRIPT
test -e /home/vagrant/.spacemacs || (
  git clone --recursive https://github.com/syl20bnr/spacemacs /home/vagrant/.emacs.d && 
  cp /home/vagrant/.emacs.d/core/templates/.spacemacs.template /home/vagrant/.spacemacs &&
  sed -i "s/emacs-lisp/emacs-lisp (haskell :variables haskell-enable-ghci-ng-support t)/g" /home/vagrant/.spacemacs &&
  sed -i "s/dotspacemacs-excluded-packages '()/dotspacemacs-excluded-packages '(exec-path-from-shell)/g" /home/vagrant/.spacemacs
)
cd /home/vagrant/.emacs.d
git pull
SCRIPT
