{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.galaxy) books;

  listenAddress = "127.0.0.1";
  stateDir = "/var/lib/audiobookshelf";

  dataDir = "audiobookshelf";
  libraryDir = "/var/lib/${dataDir}/library";

  audiobooksDir = "${libraryDir}/audiobooks";
  podcastsDir = "${libraryDir}/podcasts";
in
{
  options.galaxy = {
    books = {
      enable = lib.mkEnableOption "Enable audiobookshelf";

      port = lib.mkOption {
        type = lib.types.port;
        default = 13378;
        readOnly = true;
        description = "Port for the audiobookshelf server.";
      };
    };
  };

  config = lib.mkIf books.enable (
    lib.mkMerge [
      {
        services.audiobookshelf = {
          enable = true;
          package = pkgs.unstable.audiobookshelf;

          inherit dataDir;

          inherit (books) port;
          host = listenAddress;
        };

        systemd.tmpfiles.rules = [
          "d ${libraryDir} 0755 audiobookshelf audiobookshelf - -"
          "d ${audiobooksDir} 0755 audiobookshelf audiobookshelf - -"
          "d ${podcastsDir} 0755 audiobookshelf audiobookshelf - -"
        ];
      }

      {
        galaxy = {
          proxy.rules = [
            {
              name = "books";
              to.http = "http://${listenAddress}:${toString books.port}";
            }
          ];
          backup.paths = [ stateDir ];
        };
      }
    ]
  );
}
