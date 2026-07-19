{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.galaxy) domain peers;

  listenAddress = "127.0.0.1";
  publicUrl = "https://${peers.host}";

  serverPort = 8081;
  dashboardPort = 8080;
  stunPort = 3479;
  metricsPort = 9090;
  healthPort = 9000;
  logLevel = "info";

  stateDir = "/var/lib/netbird";
  runtimeConfig = "/run/netbird-server/config.json";

  proxyStateDir = "/var/lib/netbird-proxy";
  proxyTokenFile = "${stateDir}/proxy-token";
  proxyPort = 8443;
  proxyHealthPort = 9080;
  proxyWireGuardPort = 51821;

  hardening = {
    NoNewPrivileges = true;
    PrivateTmp = true;
    ProtectHome = true;
    ProtectSystem = "strict";
    ProtectKernelTunables = true;
    ProtectKernelModules = true;
    ProtectControlGroups = true;
    RestrictAddressFamilies = [
      "AF_INET"
      "AF_INET6"
      "AF_UNIX"
    ];
  };

  baseConfig = pkgs.writeText "netbird-server-config.json" (
    builtins.toJSON {
      server = {
        listenAddress = "${listenAddress}:${toString serverPort}";
        exposedAddress = "${publicUrl}:443";
        stunPorts = [ stunPort ];
        inherit metricsPort logLevel;
        healthcheckAddress = "${listenAddress}:${toString healthPort}";
        logFile = "console";
        dataDir = stateDir;
        disableAnonymousMetrics = true;

        auth = {
          issuer = "${publicUrl}/oauth2";
          localAuthDisabled = false;
          signKeyRefreshEnabled = true;
          dashboardRedirectURIs = [
            "${publicUrl}/nb-auth"
            "${publicUrl}/nb-silent-auth"
          ];
          cliRedirectURIs = [ "http://localhost:53000/" ];
        };

        reverseProxy = {
          trustedHTTPProxiesCount = 1;
          trustedPeers = [
            "127.0.0.1/32"
            "::1/128"
          ];
        };

        store = {
          engine = "sqlite";
          dsn = "";
        };
      };
    }
  );

  configGenerator =
    pkgs.writers.writePython3 "netbird-server-config" { } # python
      ''
        import json
        import os
        import sys

        source, destination, auth_file, encryption_file = sys.argv[1:]

        with open(source, encoding="utf-8") as f:
            config = json.load(f)


        def secret(path):
            with open(path, encoding="utf-8") as f:
                return f.read().strip()


        config["server"]["authSecret"] = secret(auth_file)
        config["server"]["store"]["encryptionKey"] = secret(encryption_file)

        os.makedirs(os.path.dirname(destination), exist_ok=True)
        temporary = destination + ".tmp"
        with open(temporary, "w", encoding="utf-8") as f:
            json.dump(config, f, indent=2)
            f.write("\n")
        os.chmod(temporary, 0o600)
        os.replace(temporary, destination)
      '';

  dashboardSettings = {
    NETBIRD_MGMT_API_ENDPOINT = publicUrl;
    NETBIRD_MGMT_GRPC_API_ENDPOINT = publicUrl;
    AUTH_AUDIENCE = "netbird-dashboard";
    AUTH_CLIENT_ID = "netbird-dashboard";
    AUTH_CLIENT_SECRET = "";
    AUTH_AUTHORITY = "${publicUrl}/oauth2";
    USE_AUTH0 = false;
    AUTH_SUPPORTED_SCOPES = "openid profile email groups";
    AUTH_REDIRECT_URI = "/nb-auth";
    AUTH_SILENT_REDIRECT_URI = "/nb-silent-auth";
    NETBIRD_TOKEN_SOURCE = "accessToken";
    NETBIRD_DRAG_QUERY_PARAMS = false;
    NETBIRD_GOOGLE_ANALYTICS_ID = "";
    NETBIRD_GOOGLE_TAG_MANAGER_ID = "";
    NETBIRD_HOTJAR_TRACK_ID = "";
    NETBIRD_WASM_PATH = "";
    NETBIRD_AUTH_SERVICE_URL = "";
    NETBIRD_LICENSED = false;
    NETBIRD_CLOUD = false;
    NETBIRD_HUBSPOT_PORTAL_ID = "";
    NETBIRD_HUBSPOT_SIGNUP_FORM_ID = "";
    NETBIRD_HUBSPOT_ONBOARDING_FORM_ID = "";
    NETBIRD_HUBSPOT_SURVEY_FORM_ID = "";
    NETBIRD_ANALYTICS_EXCLUDED_EMAILS = "";
  };

  dashboard =
    pkgs.runCommand "netbird-dashboard-${peers.host}"
      {
        nativeBuildInputs = [ pkgs.gettext ];
        env = lib.mapAttrs (
          _: value: if lib.isBool value then lib.boolToString value else toString value
        ) dashboardSettings;
        substitutions = lib.concatMapStringsSep " " (name: "\$${name}") (lib.attrNames dashboardSettings);
      }
      # bash
      ''
        cp -R ${pkgs.unstable.netbird-dashboard} build
        chmod -R u+w build

        if [[ -e build/OidcTrustedDomains.js.tmpl ]]; then
          envsubst "$substitutions" < build/OidcTrustedDomains.js.tmpl > build/OidcTrustedDomains.js
        fi

        while IFS= read -r file; do
          envsubst "$substitutions" < "$file" > "$file.substituted"
          mv "$file.substituted" "$file"
        done < <(grep -R -I -l '\$[A-Z][A-Z0-9_]*' build || true)

        cp -R build "$out"
      '';

  proxyRule = scheme: name: pathPrefix: {
    inherit name;
    priority = 100;
    from = {
      host = peers.host;
      inherit pathPrefix;
    };
    to.http = "${scheme}://${listenAddress}:${toString serverPort}";
  };
in
{
  options.galaxy.peers = {
    enable = lib.mkEnableOption "the self-hosted NetBird service";

    host = lib.mkOption {
      type = lib.types.str;
      default = "peers.${domain}";
      description = "Public NetBird dashboard and management hostname.";
    };
  };

  config = lib.mkIf peers.enable {
    users = {
      groups = {
        netbird = { };
        netbird-proxy = { };
      };
      users = {
        netbird = {
          isSystemUser = true;
          group = "netbird";
          home = stateDir;
        };
        netbird-proxy = {
          isSystemUser = true;
          group = "netbird-proxy";
          home = proxyStateDir;
        };
      };
    };

    environment.systemPackages = [
      pkgs.netbird-proxy
      pkgs.netbird-server
    ];

    systemd.services = {
      netbird-server = {
        description = "NetBird combined self-hosted server";
        documentation = [ "https://docs.netbird.io/selfhosted/selfhosted-quickstart" ];
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];

        preStart = # bash
          ''
            umask 077
            for secret in auth-secret store-encryption-key; do
              if [[ ! -s ${stateDir}/$secret ]]; then
                ${lib.getExe' pkgs.openssl "openssl"} rand -base64 32 > ${stateDir}/$secret.tmp
                mv ${stateDir}/$secret.tmp ${stateDir}/$secret
              fi
            done

            ${configGenerator} \
              ${baseConfig} \
              ${runtimeConfig} \
              ${stateDir}/auth-secret \
              ${stateDir}/store-encryption-key
          '';

        serviceConfig = hardening // {
          User = "netbird";
          Group = "netbird";
          StateDirectory = "netbird";
          StateDirectoryMode = "0750";
          RuntimeDirectory = "netbird-server";
          RuntimeDirectoryMode = "0750";
          WorkingDirectory = stateDir;
          ExecStart = "${lib.getExe pkgs.netbird-server} --config ${runtimeConfig}";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };

      netbird-proxy-token = {
        description = "Create the NetBird management-wide proxy token";
        requires = [ "netbird-server.service" ];
        after = [ "netbird-server.service" ];

        script = # bash
          ''
            set -euo pipefail
            [[ -s ${proxyTokenFile} ]] && exit 0

            for _ in $(seq 1 60); do
              ${lib.getExe pkgs.curl} --fail --silent \
                http://${listenAddress}:${toString healthPort}/health >/dev/null && break
              sleep 1
            done

            output="$(${lib.getExe pkgs.netbird-server} token create \
              --name galaxy-proxy \
              --config ${runtimeConfig})"
            token="$(printf '%s\n' "$output" | ${lib.getExe pkgs.gnused} -n 's/^Token:[[:space:]]*//p')"
            [[ -n "$token" ]]

            umask 077
            printf '%s' "$token" > ${proxyTokenFile}.tmp
            mv ${proxyTokenFile}.tmp ${proxyTokenFile}
          '';

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = "netbird";
          Group = "netbird";
          StateDirectory = "netbird";
        };
      };

      netbird-proxy = {
        description = "NetBird mesh-aware reverse proxy";
        documentation = [ "https://docs.netbird.io/manage/reverse-proxy" ];
        wantedBy = [ "multi-user.target" ];
        requires = [
          "netbird-server.service"
          "netbird-proxy-token.service"
        ];
        after = [
          "network-online.target"
          "netbird-server.service"
          "netbird-proxy-token.service"
        ];
        wants = [ "network-online.target" ];

        environment = {
          NB_PROXY_MANAGEMENT_ADDRESS = publicUrl;
          NB_PROXY_ADDRESS = "${listenAddress}:${toString proxyPort}";
          NB_PROXY_DOMAIN = peers.host;
          NB_PROXY_CERTIFICATE_DIRECTORY = "${proxyStateDir}/certs";
          NB_PROXY_ACME_CERTIFICATES = "true";
          NB_PROXY_ACME_CHALLENGE_TYPE = "tls-alpn-01";
          NB_PROXY_HEALTH_ADDRESS = "${listenAddress}:${toString proxyHealthPort}";
          NB_PROXY_FORWARDED_PROTO = "https";
          NB_PROXY_PROXY_PROTOCOL = "true";
          NB_PROXY_TRUSTED_PROXIES = "127.0.0.1/32,::1/128";
          NB_PROXY_PRIVATE = "true";
          NB_PROXY_REQUIRE_SUBDOMAIN = "true";
          NB_PROXY_WG_PORT = toString proxyWireGuardPort;
          NB_PROXY_LOG_LEVEL = logLevel;
        };

        script = ''
          export NB_PROXY_TOKEN="$(cat "$CREDENTIALS_DIRECTORY/proxy-token")"
          exec ${lib.getExe pkgs.netbird-proxy}
        '';

        serviceConfig = hardening // {
          User = "netbird-proxy";
          Group = "netbird-proxy";
          StateDirectory = "netbird-proxy";
          StateDirectoryMode = "0750";
          WorkingDirectory = proxyStateDir;
          LoadCredential = "proxy-token:${proxyTokenFile}";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };

    services = {
      nginx = {
        enable = true;
        virtualHosts."netbird-dashboard-${peers.host}" = {
          listen = [
            {
              addr = listenAddress;
              port = dashboardPort;
            }
          ];
          root = dashboard;
          locations."/".tryFiles = "$uri $uri.html $uri/ /index.html";
        };
      };

      traefik = {
        staticConfigOptions.entryPoints.websecure.allowACMEByPass = true;

        dynamicConfigOptions.tcp = {
          routers.netbird-proxy = {
            rule = lib.concatStringsSep " || " [
              "HostSNIRegexp(`^.+\\.${lib.escapeRegex peers.host}$`)"
              # Registered in NetBird as a bare custom domain.
              "HostSNI(`home.${domain}`)"
            ];
            entryPoints = [ "websecure" ];
            service = "netbird-proxy";
            priority = 1000;
            tls.passthrough = true;
          };

          services.netbird-proxy.loadBalancer = {
            servers = [ { address = "${listenAddress}:${toString proxyPort}"; } ];
            serversTransport = "netbird-proxy-proxy-protocol";
          };

          serversTransports.netbird-proxy-proxy-protocol.proxyProtocol.version = 2;
        };
      };
    };

    networking.firewall.allowedUDPPorts = [
      stunPort
      proxyWireGuardPort
    ];

    galaxy = {
      backup.paths = [
        stateDir
        proxyStateDir
      ];

      proxy.rules = [
        (proxyRule "h2c" "netbird-grpc-signal" "/signalexchange.SignalExchange/")
        (proxyRule "h2c" "netbird-grpc-management" "/management.ManagementService/")
        (proxyRule "h2c" "netbird-grpc-proxy" "/management.ProxyService/")
        (proxyRule "http" "netbird-backend-relay" "/relay")
        (proxyRule "http" "netbird-backend-ws" "/ws-proxy/")
        (proxyRule "http" "netbird-backend-api" "/api")
        (proxyRule "http" "netbird-backend-oauth2" "/oauth2")
        {
          name = "netbird-dashboard";
          priority = 1;
          from.host = peers.host;
          to.http = "http://${listenAddress}:${toString dashboardPort}";
        }
      ];
    };
  };
}
