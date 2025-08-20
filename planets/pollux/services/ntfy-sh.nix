{ config, ... }:

let
  domain = config.universe.domain;
  port = 2586;
in
{
  services.ntfy-sh = {
    enable = true;

    # See https://ntfy.sh/docs/config/#config-options for supported keys
    settings = {
      "base-url" = "https://ntfy.${domain}";
      "listen-http" = "127.0.0.1:${toString port}";
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

