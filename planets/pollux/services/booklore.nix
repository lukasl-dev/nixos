{ config, pkgs, ... }:

let
  inherit (config.universe) domain;

  port = 6060;

  stateDir = "/var/lib/booklore";
  dataDir = "${stateDir}/data";
  booksDir = "${stateDir}/books";
  bookdropDir = "${stateDir}/bookdrop";
  mariadbDir = "${stateDir}/mariadb";

  bookloreImage = "ghcr.io/booklore-app/booklore:latest";
  mariadbImage = "lscr.io/linuxserver/mariadb:11.4.5";
  uid = 2000;
  gid = 2000;
in
{
  virtualisation.oci-containers.containers = {
    booklore = {
      image = bookloreImage;
      ports = [ "127.0.0.1:${toString port}:${toString port}" ];
      environmentFiles = [ config.sops.templates."planets/pollux/booklore/app-env".path ];
      volumes = [
        "${dataDir}:/app/data:rw"
        "${booksDir}:/books:rw"
        "${bookdropDir}:/bookdrop:rw"
      ];
      extraOptions = [ "--network=booklore" ];
      dependsOn = [ "booklore-mariadb" ];
    };

    booklore-mariadb = {
      image = mariadbImage;
      environmentFiles = [ config.sops.templates."planets/pollux/booklore/db-env".path ];
      volumes = [ "${mariadbDir}:/config:rw" ];
      extraOptions = [
        "--network=booklore"
        "--network-alias=mariadb"
      ];
    };
  };

  users = {
    users.booklore = {
      isSystemUser = true;
      group = "booklore";
      inherit uid;
      home = stateDir;
    };
    groups.booklore.gid = gid;
  };

  systemd.tmpfiles.rules = [
    "d ${stateDir}      0750 booklore booklore - -"
    "d ${dataDir}       0750 booklore booklore - -"
    "d ${booksDir}      0755 booklore booklore - -"
    "d ${bookdropDir}   0775 booklore booklore - -"
    "d ${mariadbDir}    0750 booklore booklore - -"
  ];

  sops = {
    secrets = {
      "planets/pollux/booklore/db_root_password" = { };
      "planets/pollux/booklore/db_user_password" = { };
    };

    templates = {
      "planets/pollux/booklore/app-env" = {
        content = ''
          TZ=${config.planet.timeZone or "UTC"}

          DATABASE_URL=jdbc:mariadb://booklore-mariadb:3306/booklore
          DATABASE_USERNAME=booklore
          DATABASE_PASSWORD=${config.sops.placeholder."planets/pollux/booklore/db_user_password"}

          BOOKLORE_PORT=${toString port}

          PUID=${toString uid}
          PGID=${toString gid}
          USER_ID=${toString uid}
          GROUP_ID=${toString gid}
        '';
      };

      "planets/pollux/booklore/db-env" = {
        content = ''
          TZ=${config.planet.timeZone or "UTC"}
          MYSQL_ROOT_PASSWORD=${config.sops.placeholder."planets/pollux/booklore/db_root_password"}
          MYSQL_DATABASE=booklore
          MYSQL_USER=booklore
          MYSQL_PASSWORD=${config.sops.placeholder."planets/pollux/booklore/db_user_password"}
          PUID=${toString uid}
          PGID=${toString gid}
        '';
      };
    };
  };

  systemd.services.create-booklore-network = with config.virtualisation.oci-containers; {
    description = "Create Docker network for Booklore";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [
      "${backend}-booklore.service"
      "${backend}-booklore-mariadb.service"
    ];
    before = [
      "${backend}-booklore.service"
      "${backend}-booklore-mariadb.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect booklore >/dev/null 2>&1 \
        || ${pkgs.docker}/bin/docker network create booklore
    '';
  };

  services.traefik.dynamicConfigOptions.http = {
    routers.booklore = {
      rule = "Host(`books.${domain}`)";
      entryPoints = [ "websecure" ];
      service = "booklore";
    };
    services.booklore = {
      loadBalancer = {
        servers = [
          { url = "http://127.0.0.1:${toString port}"; }
        ];
        # Use a dedicated serversTransport with long timeouts for uploads
        serversTransport = "booklore-timeouts";
        responseForwarding.flushInterval = "100ms";
      };
    };
    serversTransports.booklore-timeouts.forwardingTimeouts = {
      dialTimeout = "30s";
      responseHeaderTimeout = "600s";
      idleConnTimeout = "600s";
    };
  };
}
