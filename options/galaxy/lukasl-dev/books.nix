{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.galaxy.lukasl-dev) addresses books;
in
{
  options.galaxy.lukasl-dev = {
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

  config = lib.mkIf books.enable {
    galaxy.lukasl-dev = {
      proxy.rules = [
        {
          type = "https";
          name = "books";
          http.to = "http://${addresses.local}:${toString books.port}";
        }
      ];

      modules =
        let
          dataDir = "audiobookshelf";
          libraryDir = "/var/lib/${dataDir}/library";

          audiobooksDir = "${libraryDir}/audiobooks";
          podcastsDir = "${libraryDir}/podcasts";
        in
        [
          {
            services.audiobookshelf = {
              enable = true;
              package = pkgs.unstable.audiobookshelf;

              inherit dataDir;

              inherit (books) port;
              host = addresses.local;
            };

            systemd.tmpfiles.rules = [
              "d ${libraryDir} 0755 audiobookshelf audiobookshelf - -"
              "d ${audiobooksDir} 0755 audiobookshelf audiobookshelf - -"
              "d ${podcastsDir} 0755 audiobookshelf audiobookshelf - -"
            ];

            networking.firewall.allowedTCPPorts = [ books.port ];
          }
        ];
    };

  };
}
