{ meta, config, ... }:

{
  services.harmonia = {
    enable = true;

    settings.bind = "127.0.0.1:5050";
    signKeyPath = (config.sops.secrets."harmonia/secret".path);
  };

  nix.settings.allowed-users = [ "harmonia" ];

  sops.secrets = {
    "harmonia/secret" = { };
    "harmonia/public_key" = { };
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.harmonia = {
      rule = "Host(`nix.${meta.domain}`)";
      entryPoints = [ "websecure" ];
      service = "harmonia";
    };
    services.harmonia = {
      loadBalancer.servers = [ { url = "http://${config.services.harmonia.settings.bind}"; } ];
    };
  };
}
