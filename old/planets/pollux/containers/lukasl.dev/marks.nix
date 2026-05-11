let
  meta = import ./meta.nix;

  sub = "marks";
  host = "${sub}.${meta.domain}";
  port = 2587;
in
{
  pollux.containers.${meta.container} = [
    (
      { config, ... }:
      let
        inherit (config.sops) templates placeholder;
      in
      {
        services.linkwarden = {
          enable = true;
          host = meta.address.local;
          inherit port;

          environmentFile = templates."planets/pollux/linkwarden/env".path;

          database.createLocally = true;

          enableRegistration = false;
        };

        networking.firewall.allowedTCPPorts = [ port ];

        sops = {
          secrets = {
            "planets/pollux/linkwarden/nextauth_secret" = { };
            "planets/pollux/linkwarden/postgres_password" = { };
          };

          templates."planets/pollux/linkwarden/env" = {
            content = ''
              NEXTAUTH_SECRET=${placeholder."planets/pollux/linkwarden/nextauth_secret"}
              POSTGRES_PASSWORD=${placeholder."planets/pollux/linkwarden/postgres_password"}
              NEXTAUTH_URL=https://${host}
            '';
            owner = "linkwarden";
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
