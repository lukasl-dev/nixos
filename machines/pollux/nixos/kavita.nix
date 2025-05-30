{
  meta,
  config,
  pkgs-unstable,
  ...
}:

let
  port = 2858;
in
{
  services.kavita = {
    enable = true;

    package = pkgs-unstable.kavita;
    tokenKeyFile = config.sops.secrets."kavita/token".path;

    settings = {
      Port = port;
    };
  };

  sops.secrets = {
    "kavita/token" = {
      owner = config.services.kavita.user;
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.read = {
      rule = "Host(`read.${meta.domain}`)";
      entryPoints = [ "websecure" ];
      service = "read";
    };
    services.read = {
      loadBalancer.servers = [
        {
          url = "http://localhost:${toString port}";
        }
      ];
    };
  };
}
