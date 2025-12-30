let
  meta = import ./meta.nix;

  sub = "box";

  port = 7745;
in
{
  pollux.containers.${meta.container} = [
    {
      services.homebox = {
        enable = true;

        settings = {
          HBOX_WEB_PORT = toString port;
          HBOX_WEB_HOST = meta.address.local;
          HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
          HBOX_OPTIONS_GITHUB_RELEASE_CHECK = "false";
        };
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
