{ meta, ... }:

let
  httpPort = 7297;
in
{
  services.gitea = {
    enable = true;

    appName = "Lukas' Git Server";

    settings = {
      server = {
        DOMAIN = "git.${meta.domain}";
        HTTP_PORT = httpPort;
      };

      service = {
        DISABLE_REGISTRATION = true;
      };
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.git = {
      rule = "Host(`git.${meta.domain}`)";
      entryPoints = [ "websecure" ];
      service = "git";
    };
    services.git = {
      loadBalancer.servers = [
        {
          url = "http://localhost:${toString httpPort}";
        }
      ];
    };
  };
}
