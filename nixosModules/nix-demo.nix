{ pkgs, inputs, ... }: {

    nixpkgs.overlays = [
      (_: _: {
        nix-demo-wrapper = inputs.self.packages.x86_64-linux.nix-demo-wrapper;
      })
    ];

    networking.firewall.allowedTCPPorts = [ 22 80 5432 587 443 3000 ];

    systemd.services.nix-demo = {
      description = "nix-demo";
      enable = true;
      wantedBy = [ "multi-user.target" "nginx.service" ];
      after = [ "network.service" "local-fs.target" ];
      environment = {
        YESOD_STATIC_DIR="/home/admin/nix-demo/static";
        YESOD_PORT="3000";
        YESOD_APPROOT="https://nix-demo.hhefesto.com";
      };
      serviceConfig = {
        Type = "simple";
        User = "admin";
        WorkingDirectory = "/home/admin/nix-demo";
        ExecStart = ''${pkgs.nix-demo-wrapper}/bin/nix-demo-wrapped'';
        ExecStop = "";
        Restart = "always";
      };
    };

    security.acme.acceptTerms = true;
    security.acme.defaults.email = "dherrera@fpcomplete.com";

    services.nginx = {
      enable = true;

      virtualHosts."nix-demo.hhefesto.com" = {
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
}
