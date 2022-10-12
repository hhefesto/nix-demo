{
  # This is a template created by `hix init`
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        overlays = [ haskellNix.overlay
          (final: prev: {
            nix-demo =
              final.haskell-nix.project {
                projectFileName = "stack.yaml";
                src = builtins.path { name = "nix-demo-src"; path = ./.;};
                shell.buildInputs = with pkgs; [
                  stack
                  nixpkgs-fmt
                  postgresql
                  nixUnstable
                ];
                shell.additional = hsPkgs: with hsPkgs; [ Cabal ];
              };
          })
        ];
        pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
        flake = pkgs.nix-demo.flake {};
      in flake // {
        packages = flake.packages // {
          default = flake.packages."nix-demo:exe:nix-demo";
        };
        apps = flake.apps // { default = flake.apps."nix-demo:exe:nix-demo"; };
        legacyPackages = pkgs;
      });

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
