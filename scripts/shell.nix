{app, compiler ? null, overrides ? (self: {})}:
let pkgs = (import <nixpkgs> {}).pkgs;
    hsp = if compiler == null then pkgs.haskellPackages else pkgs.haskell.packages.${compiler};
    regularCompiler = if compiler == "ghcjs" then pkgs.haskellPackages else pkgs.haskell.packages.${compiler};
    hsPkgs = hsp.override { overrides = self: super: overrides self; };
    appPackage = hsp.callPackage app {};
in pkgs.lib.overrideDerivation appPackage.env (old: {buildInputs = old.buildInputs ++ [regularCompiler.ghc hsp.ghc regularCompiler.cabal-install];})
