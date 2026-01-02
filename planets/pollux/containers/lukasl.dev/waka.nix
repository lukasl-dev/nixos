let
  meta = import ./meta.nix;

  sub = "waka";

  host = "${sub}.${meta.domain}";
  port = 3000;
in
{
  pollux.containers.${meta.container} = [
    (
      { config, ... }:
      let
        inherit (config.sops) secrets;
      in
      {
        services.wakapi = {
          enable = true;

          passwordSaltFile = secrets."planets/pollux/wakapi/salt".path;

          settings = {
            server = {
              public_url = "https://${host}";
              listen_ipv4 = meta.address.local;
              inherit port;
            };

            security = {
              insecure_cookies = false;
              allow_signup = false;
            };
          };
        };

        networking.firewall.allowedTCPPorts = [ port ];

        sops.secrets."planets/pollux/wakapi/salt" = {
          owner = "wakapi";
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
        rule = "Host(`${host}`)";
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
