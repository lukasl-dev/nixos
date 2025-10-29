{ config, lib, ... }:

let
  inherit (config.universe) domain;

  host = "auth.${domain}";
  port = 9091;
  metricsPort = 9961;

  routerName = "authelia";
  serviceName = routerName;

  upstream = "http://127.0.0.1:${toString port}";

  autheliaUser = config.services.authelia.instances.main.user;
  autheliaGroup = config.services.authelia.instances.main.group;
in
{
  services.authelia.instances.main = {
    enable = true;

    secrets = {
      jwtSecretFile = config.sops.secrets."planets/pollux/authelia/jwt_secret".path;
      storageEncryptionKeyFile = config.sops.secrets."planets/pollux/authelia/storage_key".path;
      sessionSecretFile = config.sops.secrets."planets/pollux/authelia/session_secret".path;
    };

    environmentVariables = {
      AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE =
        config.sops.templates."planets/pollux/authelia/smtp_password".path;
    };

    settings = {
      theme = "auto";
      log = {
        level = "info";
        format = "text";
      };

      # Listen only on loopback; Traefik terminates TLS and proxies.
      server.address = "tcp://127.0.0.1:${toString port}";

      telemetry.metrics = {
        enabled = false;
        address = "tcp://127.0.0.1:${toString metricsPort}";
      };

      default_2fa_method = "webauthn";

      authentication_backend.file = {
        path = config.sops.secrets."planets/pollux/authelia/users".path;
        search = {
          email = true;
          case_insensitive = true;
        };
      };

      session = {
        cookies = [
          {
            domain = domain;
            authelia_url = "https://${host}";
            default_redirection_url = "https://${domain}";
            same_site = "lax";
          }
        ];

        redis.host = config.services.redis.servers.authelia.unixSocket;
      };

      storage.local.path = "/var/lib/authelia/storage.sqlite3";

      access_control = {
        default_policy = "one_factor";
      };

      notifier.smtp = {
        address = "submissions://mail.${domain}:465";
        username = "bot@${domain}";
        sender = "Auth <bot@${domain}>";
        timeout = "5s";
        disable_require_tls = false;
      };
    };
  };

  # Dedicated Redis for Authelia sessions via UNIX socket
  services.redis.servers.authelia = {
    enable = true;
    port = 0; # socket only
    user = autheliaUser;
    unixSocketPerm = 660;
  };

  sops = {
    secrets = {
      "planets/pollux/authelia/jwt_secret" = {
        owner = autheliaUser;
      };
      "planets/pollux/authelia/storage_key" = {
        owner = autheliaUser;
      };
      "planets/pollux/authelia/session_secret" = {
        owner = autheliaUser;
      };
      "planets/pollux/authelia/users" = {
        owner = autheliaUser;
      };
    };
    templates."planets/pollux/authelia/smtp_password" = {
      owner = autheliaUser;
      content = "${config.sops.placeholder.\"planets/pollux/maddy/bot\"}";
    };
  };

  # Ensure the SQLite directory exists with correct ownership.
  systemd.tmpfiles.rules = [
    "d /var/lib/authelia 0750 ${autheliaUser} ${autheliaGroup} -"
  ];

  services.traefik.dynamicConfigOptions.http = {
    routers.${routerName} = {
      rule = "Host(`${host}`)";
      entryPoints = [ "websecure" ];
      service = serviceName;
    };

    services.${serviceName} = {
      loadBalancer = {
        passHostHeader = true;
        servers = [ { url = upstream; } ];
      };
    };

    middlewares.authelia.forwardAuth = {
      address = "${upstream}/api/authz/forward-auth";
      trustForwardHeader = true;
      authResponseHeaders = [
        "Remote-User"
        "Remote-Groups"
        "Remote-Email"
        "Remote-Name"
      ];
    };
  };

  # Ensure tmpfiles runs before Authelia so the storage directory exists
  systemd.services.authelia-main = {
    after = [ "systemd-tmpfiles-setup.service" ];
    requires = [ "systemd-tmpfiles-setup.service" ];
  };
}
