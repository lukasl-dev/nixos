let
  meta = import ./meta.nix;

  sub = "metrics";

  port = 8831;
in
{
  pollux.containers.${meta.container} = [
    {
      services.prometheus = {
        enable = true;

        inherit port;
      };

      networking.firewall.allowedTCPPorts = [ port ];
    }
  ];

  services.traefik.dynamicConfigOptions.http =
    let
      name = meta.router sub;
    in
    {
      routers.${name} = {
        rule = "Host(`${sub}.${meta.domain}`)";
        entryPoints = [ "websecure" ];
        service = name;
      };
      services.${name} = {
        loadBalancer.servers = [
          {
            url = "http://${meta.address.local}:${toString port}";
          }
        ];
      };
    };
}
