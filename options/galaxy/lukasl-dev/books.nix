{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.galaxy.lukasl-dev) addresses books;

  isGuest = books.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";
  stateDir = "/var/lib/audiobookshelf";
in
{
  options.galaxy.lukasl-dev = {
    books = {
      enable = lib.mkEnableOption "Enable audiobookshelf";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run audiobookshelf in the lukasl-dev container or on the host.";
      };

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
          to.http = "http://${listenAddress}:${toString books.port}";
        }
      ];

      backup.paths = [
        (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
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
            inherit (books) mode;

            module = {
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

              networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ books.port ];
            };
          }
        ];
    };

  };
}
