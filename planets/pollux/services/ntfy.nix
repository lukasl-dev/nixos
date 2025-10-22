{ config, pkgs-unstable, ... }:

let
  inherit (config.universe) domain;
  port = 2586;
in
{
  disabledModules = [ "services/misc/ntfy-sh.nix" ];
  imports = [ (pkgs-unstable.path + "/nixos/modules/services/misc/ntfy-sh.nix") ];

  services.ntfy-sh = {
    enable = true;
    package = pkgs-unstable.ntfy-sh;

    settings = {
      base-url = "https://ntfy.${domain}";
      listen-http = "127.0.0.1:${toString port}";
      behind-proxy = true;
      enable-login = true;
      require-login = true;
      auth-default-access = "deny-all";
    };

    environmentFile = config.sops.templates."planets/${config.planet.name}/ntfy/env".path;
  };

  sops = {
    secrets = {
      "planets/${config.planet.name}/ntfy/users" = { };
    };

    templates."planets/${config.planet.name}/ntfy/env" = {
      content = ''
        NTFY_AUTH_USERS=${config.sops.placeholder."planets/${config.planet.name}/ntfy/users"}
      '';
      owner = config.services.ntfy-sh.user;
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.ntfy = {
      rule = "Host(`ntfy.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "ntfy";
    };
    services.ntfy = {
      loadBalancer = {
        passHostHeader = true;
        servers = [
          { url = "http://localhost:${toString port}"; }
        ];
      };
    };
  };
}
