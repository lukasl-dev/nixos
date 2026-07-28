{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config.planet.hosting) media;
  inherit (atlas.hosting.media) host;

  listenAddress = "127.0.0.1";
  port = 8096;
  dataDir = "/var/lib/jellyfin";
in
{
  options.planet.hosting.media.enable =
    lib.mkEnableOption "Jellyfin media server";

  config = lib.mkIf media.enable {
    services.jellyfin = {
      enable = true;
      inherit dataDir;
    };

    planet = {
      backup.dirs = [ dataDir ];

      hosting.proxy.rules.media = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
