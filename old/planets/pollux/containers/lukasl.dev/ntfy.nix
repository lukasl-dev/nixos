let
  meta = import ./meta.nix;

  sub = "ntfy";

  host = "ntfy.${meta.domain}";
  port = 2586;
in
{
  pollux.containers.${meta.container} = [
    (
      { config, ... }:
      let
        inherit (config.sops) templates placeholder;
      in
      {
        services.ntfy-sh = {
          enable = true;

          settings = {
            base-url = "https://${host}";
            listen-http = "${meta.address.local}:${toString port}";
            behind-proxy = true;
            enable-login = true;
            require-login = true;
            auth-default-access = "deny-all";
          };

          environmentFile = templates."planets/pollux/ntfy/env".path;
        };

        networking.firewall.allowedTCPPorts = [ port ];

        sops = {
          secrets."planets/pollux/ntfy/users" = { };

          templates."planets/pollux/ntfy/env" = {
            content = ''
              NTFY_AUTH_USERS=${placeholder."planets/pollux/ntfy/users"}
            '';
            owner = config.services.ntfy-sh.user;
          };
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
