{app, compiler ? null, overrides ? (self: {})}:
with (import <nixpkgs> {}).pkgs;
let hsp = if compiler == null then pkgs.haskellPackages else pkgs.haskell.packages.${compiler};
    hsPkgs = hsp.override { overrides = self: super: overrides self; };
    appPackage = with hsPkgs; callPackage app {};
in pkgs.lib.overrideDerivation appPackage.env (old: {buildInputs = old.buildInputs ++ [pkgs.haskellPackages.cabal-install hsPkgs.ghc];})