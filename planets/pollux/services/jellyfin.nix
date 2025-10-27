{ config, pkgs-unstable, ... }:

let
  inherit (config.universe) domain;

  port = 8096;
in
{
  services.jellyfin = {
    enable = true;

    package = pkgs-unstable.jellyfin;
  };

  environment.systemPackages = [
    pkgs-unstable.jellyfin
    pkgs-unstable.jellyfin-web
    pkgs-unstable.jellyfin-ffmpeg
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.jellyfin = {
      rule = "Host(`media.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "jellyfin";
    };
    services.jellyfin = {
      loadBalancer.servers = [
        {
          url = "http://localhost:${toString port}";
        }
      ];
    };
  };
}
