{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config.planet.hosting) media;
  inherit (atlas.hosting.media) host;

  steward = atlas.travellers.eval config.planet.steward.traveller;

  listenAddress = "127.0.0.1";
  port = 8096;
  dataDir = "/var/lib/jellyfin";

  mediaDir = "/srv/media";
  libraryDirs = map (library: "${mediaDir}/${library}") [
    "lectures"
    "movies"
    "music"
    "photos"
    "shows"
  ];
in
{
  options.planet.hosting.media.enable =
    lib.mkEnableOption "Jellyfin media server";

  config = lib.mkIf media.enable {
    services.jellyfin = {
      enable = true;
      inherit dataDir;
    };

    users = {
      groups.media = { };
      users.jellyfin.extraGroups = [ "media" ];
    };

    systemd.tmpfiles.rules = [
      "d ${mediaDir} 2750 ${steward.user.name} media - -"
    ]
    ++ map (dir: "d ${dir} 2750 ${steward.user.name} media - -") libraryDirs;

    systemd.services.jellyfin.serviceConfig.SupplementaryGroups = [ "media" ];

    planet = {
      backup.dirs = [ dataDir ];
      steward.groups = [ "media" ];

      hosting.proxy.rules.media = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
