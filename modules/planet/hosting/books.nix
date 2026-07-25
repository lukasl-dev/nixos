{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config.planet.hosting) books;
  inherit (atlas.hosting.books) host;

  listenAddress = "127.0.0.1";
  port = 13378;

  dataDir = "audiobookshelf";
  stateDir = "/var/lib/${dataDir}";
  libraryDir = "${stateDir}/library";
  audiobooksDir = "${libraryDir}/audiobooks";
  podcastsDir = "${libraryDir}/podcasts";
in
{
  options.planet.hosting.books.enable =
    lib.mkEnableOption "Audiobookshelf server";

  config = lib.mkIf books.enable {
    services.audiobookshelf = {
      enable = true;
      inherit dataDir port;
      host = listenAddress;
    };

    systemd.tmpfiles.rules = [
      "d ${libraryDir} 0755 audiobookshelf audiobookshelf - -"
      "d ${audiobooksDir} 0755 audiobookshelf audiobookshelf - -"
      "d ${podcastsDir} 0755 audiobookshelf audiobookshelf - -"
    ];

    planet = {
      backup.dirs = [ stateDir ];

      hosting.proxy.rules.books = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
