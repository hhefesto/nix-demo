{
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixops.url = "github:input-output-hk/nixops-flake";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };
  outputs = { self, nixpkgs, flake-utils, haskellNix, flake-compat, nixops }:
    let
      overlays = [ haskellNix.overlay
        (final: prev: {
          nix-demo =
            final.haskell-nix.project {
              projectFileName = "stack.yaml";
              src = final.haskell-nix.haskellLib.cleanGit {
                name = "nix-demo-src";
                src = ./.;
              };
              shell.buildInputs = with pkgs; [
                stack
                nixpkgs-fmt
                postgresql
                # nixops.packages.${system}.default
                # nixops_unstable
              ];
              shell.additional = hsPkgs: with hsPkgs; [ Cabal ];
              shell.nativeBuildInputs = [ nixops.defaultPackage.x86_64-linux ];
              # shell.nativeBuildInputs = [ final.nixops_unstable ];
            };
          configuration-files = pkgs.runCommand "staticFilesAanalyzer" { src = ./.; } ''
             mkdir -p $out/config
             mkdir -p $out/static
             cp -R $src/config $out/
             cp -R $src/static $out/
           '';
        })
      ];
      pkgs = import nixpkgs { system = "x86_64-linux"; inherit overlays; inherit (haskellNix) config; };
      flake = pkgs.nix-demo.flake {};
    in flake-utils.lib.eachSystem [ "x86_64-linux" ] (system: flake // {
      packages = flake.packages // {
        default = flake.packages."nix-demo:exe:nix-demo";
        configuration-files = pkgs.configuration-files;
      };
      apps = flake.apps // { default = flake.apps."nix-demo:exe:nix-demo"; };
      legacyPackages = pkgs;
      nixopsConfigurations.default = import ./nix-demo-configuration.nix { inherit nixpkgs pkgs; };
    }) // { nixopsConfigurations.default = import ./nix-demo-configuration.nix { inherit pkgs nixpkgs; }; };

  # --- Flake Local Nix Configuration ----------------------------
  nixConfig = {
    # This sets the flake to use the IOG nix cache.
    # Nix should ask for permission before using it,
    # but remove it here if you do not want it to.
    extra-substituters = ["https://cache.iog.io"];
    extra-trusted-public-keys = ["hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="];
    allow-import-from-derivation = "true";
  };
}
