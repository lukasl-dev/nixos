let
  meta = import ./meta.nix;

  sub = "pdf";
  host = "${sub}.${meta.domain}";
  port = 2588;
in
{
  pollux.containers.${meta.container} = [
    (
      { config, ... }:
      let
        inherit (config.sops) templates placeholder;
      in
      {
        services.stirling-pdf = {
          enable = true;
          environment = {
            SERVER_PORT = port;
            SECURITY_ENABLE_LOGIN = "true";
          };
          environmentFiles = [
            templates."planets/pollux/pdf/env".path
          ];
        };

        networking.firewall.allowedTCPPorts = [ port ];

        sops = {
          secrets = {
            "planets/pollux/pdf/admin_username" = { };
            "planets/pollux/pdf/admin_password" = { };
          };

          templates."planets/pollux/pdf/env" = {
            content = ''
              SECURITY_INIT_ADMIN_USERNAME=${placeholder."planets/pollux/pdf/admin_username"}
              SECURITY_INIT_ADMIN_PASSWORD=${placeholder."planets/pollux/pdf/admin_password"}
            '';
            owner = "stirling-pdf";
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
