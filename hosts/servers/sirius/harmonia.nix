{ config, ... }:

{
  services.harmonia = {
    enable = true;

    settings.bind = "127.0.0.1:5050";
    signKeyPath = (config.sops.secrets."harmonia/secret".path);
  };

  nix.settings.allowed-users = [ "harmonia" ];

  services.traefik.dynamicConfigOptions.http = {
    routers.harmonia = {
      rule = "Host(`nix.lukasl.dev`)";
      entryPoints = [ "websecure" ];
      service = "harmonia";
      tls.certResolver = "letsencrypt";
    };
    services.harmonia = {
      loadBalancer.servers = [ { url = "http://${config.services.harmonia.settings.bind}"; } ];
    };
  };
}
