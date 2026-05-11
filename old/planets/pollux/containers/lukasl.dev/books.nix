{ pkgs, ... }:

let
  meta = import ./meta.nix;

  sub = "books";
  hostName = "${sub}.${meta.domain}";
  port = 13378;

  dataDir = "audiobookshelf";
  libraryDir = "/var/lib/${dataDir}/library";
  audiobooksDir = "${libraryDir}/audiobooks";
  podcastsDir = "${libraryDir}/podcasts";
in
{
  pollux.containers.${meta.container} = [
    {
      services.audiobookshelf = {
        enable = true;
        package = pkgs.unstable.audiobookshelf;

        inherit dataDir port;
        host = meta.address.local;
      };

      systemd.tmpfiles.rules = [
        "d ${libraryDir} 0755 audiobookshelf audiobookshelf - -"
        "d ${audiobooksDir} 0755 audiobookshelf audiobookshelf - -"
        "d ${podcastsDir} 0755 audiobookshelf audiobookshelf - -"
      ];

      networking.firewall.allowedTCPPorts = [ port ];
    }
  ];

  services.traefik.dynamicConfigOptions.http =
    let
      name = meta.router sub;
    in
    {
      routers.${name} = {
        rule = "Host(`${hostName}`)";
        entryPoints = [ "websecure" ];
        service = name;
      };
      services.${name} = {
        loadBalancer.servers = [
          {
            url = "http://${meta.address.local}:${toString port}";
          }
        ];
      };
    };
}
