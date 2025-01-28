{
  meta,
  ...
}:

let
  port = 3141;
in
{
  virtualisation.oci-containers.containers = {
    koodo-reader = {
      image = "ghcr.io/koodo-reader/koodo-reader:master";
      ports = [ "${toString port}:80" ];
    };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.koodo-reader = {
      rule = "Host(`books.${meta.domain}`)";
      entryPoints = [ "websecure" ];
      service = "koodo-reader";
    };
    services.koodo-reader = {
      loadBalancer.servers = [
        {
          url = "http://127.0.0.1:${toString port}";
        }
      ];
    };
  };
}
