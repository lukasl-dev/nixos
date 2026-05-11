let
  meta = import ./meta.nix;

  sub = "anki";

  port = 27701;
in
{
  pollux.containers.${meta.container} = [
    (
      { config, ... }:
      let
        inherit (config.sops) secrets;
      in
      {
        services.anki-sync-server = {
          enable = true;

          address = meta.address.local;
          inherit port;

          users = [
            {
              username = "lukas";
              passwordFile = secrets."planets/pollux/anki/password".path;
            }
          ];
        };

        networking.firewall.allowedTCPPorts = [ port ];

        sops.secrets = {
          "planets/pollux/anki/password" = { };
        };
      }
    )
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
