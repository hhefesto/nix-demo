{ nixpkgs, pkgs }:
{
  inherit nixpkgs;
  network.description = "something";
  server0 = { ... }: {
    # imports = [
    #   {
    #     nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
    #     # NOTE Using this is satisfactory in lieu of a specialArgs option.
    #     nixpkgs.pkgs = pkgs;
    #   }
    # ];
    deployment.targetEnv = "gce";
    deployment.gce = {
      key = "AIzaSyBYABMqA3TNOMiS-0t5p_Xf2nATdaavwQk";
      project = "simspacepresentation";
      serviceAccount = "1079565167768-compute@developer.gserviceaccount.com";
      accessKey = "~/.ssh/simspacepresentation-51774c2e83a4.json";
      #################
      # instance properties
      region = "us-west2-b";
      instanceType = "g1-small";
      tags = [ "simspace-firewall-tag" ];
      scheduling.automaticRestart = true;
      scheduling.onHostMaintenance = "MIGRATE";

      rootDiskSize = 40;
    } ;

    # nixpkgs.overlays = [
    #   (final: prev: {
    #     nix-demo = (import ./. {}).packages.x86_64-linux.default;
    #     configuration-files = (import ./. {}).packages.x86_64-linux.configuration-files;
    #   })
    # ];

    networking.firewall.allowedTCPPorts = [ 22 80 5432 587 443 ];

    systemd.services.demo-nix =
      { description = "demo-nix";
        enable = true;
        wantedBy = [ "multi-user.target" "nginx.service" ];
        after = [ "network.service" "local-fs.target" ];
        environment = {
          YESOD_STATIC_DIR="${pkgs.configuration-files}/static";
          YESOD_PORT="3000";
          YESOD_APPROOT="https://nix-demo.hhefesto.com";
        };
        serviceConfig = {
          Type = "simple";
          User = "root";
          WorkingDirectory = "${pkgs.configuration-files}";
          ExecStart = ''${pkgs.nix-demo}/bin/nix-demo'';
          ExecStop = "";
          Restart = "always";
        };
      };
    security.acme.acceptTerms = true;
    security.acme.email = "dherrera@fpcomplete.com";

    services.nginx = {
      enable = true;

      virtualHosts."nix-demo.hhefesto.org" = {
        enableACME = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://localhost:3000";
          };
        };
      };
      };

    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_11;
      enableTCPIP = true;
      authentication = pkgs.lib.mkOverride 10 ''
        local all all trust
        host all all ::1/128 trust
      '';
      initialScript = pkgs.writeText "backend-initScript" ''
        CREATE ROLE nixdemo WITH LOGIN PASSWORD 'nixdemo';
        CREATE DATABASE nixdemo;
        GRANT ALL PRIVILEGES ON DATABASE nixdemo TO nixdemo;
      '';
    };

    environment.systemPackages = with pkgs; [
      git
      msmtp
      vim
      emacs
      zsh
    ];

    # Set your time zone.
    time.timeZone = "America/Mexico_City";
    users.users.root.initialHashedPassword = "$6$/RvS0Se.iCx$A0eA/8PzgMj.Ms9ohNamfu53c9S.zdG30hEmUHLjmWP0CaXTPVA6QxGIZ6fy.abkjSOTJMAq7fFL6LUBGs4BU0";
    users.users.root.shell = pkgs.zsh;
    users.extraUsers.hhefesto = {
      createHome = true;
      isNormalUser = true;
      home = "/home/hhefesto";
      description = "Daniel Herrera";
      extraGroups = [ "wheel" "networkmanager" "docker" ];
      hashedPassword = "$6$/RvS0Se.iCx$A0eA/8PzgMj.Ms9ohNamfu53c9S.zdG30hEmUHLjmWP0CaXTPVA6QxGIZ6fy.abkjSOTJMAq7fFL6LUBGs4BU0";
      shell = pkgs.zsh; #"/run/current-system/sw/bin/bash";
    };
  };
}
