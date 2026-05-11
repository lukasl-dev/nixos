let
  meta = import ./meta.nix;

  sub = "fin";

  virtualHost = "${sub}.${meta.domain}";
  port = 7128;
in
{
  pollux.containers.${meta.container} = [
    (
      { config, ... }:
      let
        inherit (config.sops) secrets;
      in
      {
        services.firefly-iii = {
          enable = true;

          enableNginx = true;
          inherit virtualHost;

          settings = {
            APP_ENV = "production";
            APP_URL = "https://${virtualHost}";
            APP_KEY_FILE = secrets."planets/pollux/firefly/key".path;
            SITE_OWNER = "me@${meta.domain}";
            TRUSTED_PROXIES = "*";
          };
        };

        systemd.tmpfiles.rules =
          let
            inherit (config.services.firefly-iii) user group;
          in
          [
            "d /var/lib/firefly-iii 0750 ${user} ${group} -"
            "d /var/lib/firefly-iii/storage 0750 ${user} ${group} -"
            "d /var/lib/firefly-iii/storage/database 0750 ${user} ${group} -"
          ];

        services.nginx.virtualHosts.${virtualHost} = {
          enableACME = false;
          listen = [
            {
              addr = meta.address.local;
              inherit port;
            }
          ];
        };

        networking.firewall.allowedTCPPorts = [ port ];

        sops.secrets."planets/pollux/firefly/key" = {
          owner = config.services.firefly-iii.user;
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
        rule = "Host(`${virtualHost}`)";
        entryPoints = [ "websecure" ];
        service = name;
      };
      services.${name} = {
        loadBalancer = {
          passHostHeader = true;
          servers = [
            {
              url = "http://${meta.address.local}:${toString port}";
            }
          ];
        };
      };
    };
}
