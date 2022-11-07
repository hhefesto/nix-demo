{
  # This is a template created by `hix init`
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
  inputs.deploy-rs = {
    url = "github:serokell/deploy-rs";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs@{ self, nixpkgs, flake-utils, haskellNix, flake-utils-plus, deploy-rs }:
    let
      nixosModules = flake-utils-plus.lib.exportModules (
        nixpkgs.lib.mapAttrsToList (name: value: ./nixosModules/${name}) (builtins.readDir ./nixosModules)
      );
      # overlays = [ haskellNix.overlay
      #   (final: prev: {
      #     nix-demo =
      #       final.haskell-nix.project {
      #         src = ./.;
      #         shell.buildInputs = with pkgs; [
      #           stack
      #           nixpkgs-fmt
      #           postgresql
      #           nixUnstable
      #           inputs.deploy-rs.defaultPackage.x86_64-linux
      #         ];
      #         shell.additional = hsPkgs: with hsPkgs; [ Cabal ];
      #       };
      #     nix-demo-wrapper = pkgs.writeShellApplication {
      #       name = "nix-demo-wrapped";
      #       runtimeInputs = [ self.packages.x86_64-linux.default ];
      #       text = ''
      #        cd /home/admin
      #        [ ! -d "/home/admin/nix-demo" ] && git clone https://github.com/hhefesto/nix-demo
      #        cd nix-demo
      #        ${self.packages.x86_64-linux.default}/bin/nix-demo
      #       '';
      #     };
      #   })
      # ];
      # pkgs = import nixpkgs { system = "x86_64-linux"; inherit overlays; inherit (haskellNix) config; };
      # flake = pkgs.nix-demo.flake {};
      flake-deploy-rs = flake-utils-plus.lib.mkFlake {
        inherit self inputs nixosModules;

        hosts = {
          hetzner.modules = with nixosModules; [
            # nix-demo
            common
            admin
            hardware-hetzner
          ];
        };

        deploy.nodes = {
          my-node = {
            hostname = "65.108.147.207";
            fastConnection = false;
            profiles = {
              my-profile = {
                sshUser = "admin";
                path =
                  inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.hetzner;
                user = "root";
              };
            };
          };
        };
      };

    # in flake-utils.lib.eachSystem [ "x86_64-linux" ] (system: flake // {
    #     packages = flake.packages // {
    #       default = flake.packages."nix-demo:exe:nix-demo";
    #       nix-demo-wrapper = pkgs.nix-demo-wrapper;
    #     };
    #     apps = flake.apps // { default = flake.apps."nix-demo:exe:nix-demo"; };

    #     legacyPackages = pkgs;
    #   }) // flake-deploy-rs;
    in flake-deploy-rs;

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
