{ config, pkgs, inputs, ... }:

{
  time.timeZone = "UTC";
  services.openssh = { enable = true; };
  system.stateVersion = "21.11";

  nix = {
    # Currently needed for flake support, might not be needed in the future
    package = pkgs.nixUnstable;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    # from flake-utils-plus
    # Sets NIX_PATH to follow this flake's nix inputs
    # So legacy nix-channel is not needed
    generateNixPathFromInputs = true;
    linkInputs = true;
    # Pin our nixpkgs flake to the one used to build the system
    generateRegistryFromInputs = true;
  };
  nix.settings.substituters = [ "https://cache.iog.io"
                                "https://iog.cachix.org"
                              ];

  nix.settings.trusted-public-keys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
                                     ];

  # Set the system revision to the flake revision
  # You can query this value with: $ nix-info -m
  system.configurationRevision = (if inputs.self ? rev then inputs.self.rev else null);
}
