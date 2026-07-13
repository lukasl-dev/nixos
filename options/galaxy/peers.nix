{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.galaxy) domain peers;

  listenAddress = "127.0.0.1";
  stateDir = "/var/lib/netbird";
  runtimeConfig = "/run/netbird-server/config.json";
  publicUrl = "https://${peers.host}";

  proxyStateDir = "/var/lib/netbird-proxy";
  proxyTokenFile = "${stateDir}/proxy-token";
  proxyListenPort = 8443;
  proxyHealthPort = 9080;
  proxyWireGuardPort = 51821;

  baseConfig = pkgs.writeText "netbird-server-config.json" (builtins.toJSON {
    server = {
      listenAddress = "${listenAddress}:${toString peers.port}";
      exposedAddress = "${publicUrl}:443";
      stunPorts = [ peers.stunPort ];
      metricsPort = peers.metricsPort;
      healthcheckAddress = "${listenAddress}:${toString peers.healthcheckPort}";
      logLevel = peers.logLevel;
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
  });

  configGenerator = pkgs.writers.writePython3 "netbird-server-config" { } ''
    import json
    import os
    import sys

    source, destination, auth_secret_file, encryption_key_file = sys.argv[1:]

    with open(source, "r", encoding="utf-8") as f:
        config = json.load(f)


    def read_secret(path):
        with open(path, "r", encoding="utf-8") as f:
            return f.read().strip()


    server = config["server"]
    server["authSecret"] = read_secret(auth_secret_file)
    server["store"]["encryptionKey"] = read_secret(encryption_key_file)

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

  toStringEnv = value: if lib.isBool value then lib.boolToString value else toString value;

  dashboard =
    pkgs.runCommand "netbird-dashboard-${peers.host}"
      {
        nativeBuildInputs = [ pkgs.gettext ];
        env = (lib.mapAttrs (_: toStringEnv) dashboardSettings) // {
          ENV_STR = lib.concatStringsSep " " (
            map (name: "${"$"}${name}") (lib.attrNames dashboardSettings)
          );
        };
      }
      ''
        cp -R ${pkgs.unstable.netbird-dashboard} build
        chmod -R u+w build

        oidc_trusted_domains="build/OidcTrustedDomains.js"
        if [[ -e "$oidc_trusted_domains.tmpl" ]]; then
          envsubst "$ENV_STR" < "$oidc_trusted_domains.tmpl" > "$oidc_trusted_domains"
        fi

        while IFS= read -r file; do
          cp "$file" "$file.copy"
          envsubst "$ENV_STR" < "$file.copy" > "$file"
          rm "$file.copy"
        done < <(grep -R -I -l '\$[A-Z][A-Z0-9_]*' build || true)

        cp -R build "$out"
      '';

  backendRule = name: pathPrefix: {
    inherit name;
    priority = 100;
    from = {
      host = peers.host;
      inherit pathPrefix;
    };
    to.http = "http://${listenAddress}:${toString peers.port}";
  };

  grpcRule = name: pathPrefix: {
    inherit name;
    priority = 100;
    from = {
      host = peers.host;
      inherit pathPrefix;
    };
    to.http = "h2c://${listenAddress}:${toString peers.port}";
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

    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Local combined HTTP, gRPC, and WebSocket port.";
    };

    dashboardPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Local static dashboard port.";
    };

    stunPort = lib.mkOption {
      type = lib.types.port;
      default = 3479;
      description = "Public UDP port used by NetBird's embedded STUN server.";
    };

    metricsPort = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = "Local NetBird metrics port.";
    };

    healthcheckPort = lib.mkOption {
      type = lib.types.port;
      default = 9000;
      description = "Local NetBird healthcheck port.";
    };

    logLevel = lib.mkOption {
      type = lib.types.enum [
        "panic"
        "fatal"
        "error"
        "warn"
        "info"
        "debug"
        "trace"
      ];
      default = "info";
      description = "NetBird server log level.";
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

    systemd.services.netbird-server = {
      description = "NetBird combined self-hosted server";
      documentation = [ "https://docs.netbird.io/selfhosted/selfhosted-quickstart" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      preStart = ''
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

      serviceConfig = {
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
    };

    systemd.services.netbird-proxy-token = {
      description = "Create the NetBird management-wide proxy token";
      requires = [ "netbird-server.service" ];
      after = [ "netbird-server.service" ];

      script = ''
        set -euo pipefail

        if [[ -s ${proxyTokenFile} ]]; then
          exit 0
        fi

        for _ in $(seq 1 60); do
          if ${lib.getExe pkgs.curl} --fail --silent \
            http://${listenAddress}:${toString peers.healthcheckPort}/health >/dev/null; then
            break
          fi
          sleep 1
        done

        output="$(${lib.getExe pkgs.netbird-server} token create \
          --name galaxy-proxy \
          --config ${runtimeConfig})"
        token="$(printf '%s\n' "$output" | ${lib.getExe pkgs.gawk} '$1 == "Token:" { print $2 }')"
        test -n "$token"

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

    systemd.services.netbird-proxy = {
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
        NB_PROXY_ADDRESS = "${listenAddress}:${toString proxyListenPort}";
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
        NB_PROXY_LOG_LEVEL = peers.logLevel;
      };

      script = ''
        export NB_PROXY_TOKEN="$(cat "$CREDENTIALS_DIRECTORY/proxy-token")"
        exec ${lib.getExe pkgs.netbird-proxy}
      '';

      serviceConfig = {
        User = "netbird-proxy";
        Group = "netbird-proxy";
        StateDirectory = "netbird-proxy";
        StateDirectoryMode = "0750";
        WorkingDirectory = proxyStateDir;
        LoadCredential = "proxy-token:${proxyTokenFile}";
        Restart = "on-failure";
        RestartSec = "5s";

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
    };

    services.nginx = {
      enable = true;
      virtualHosts."netbird-dashboard-${peers.host}" = {
        listen = [
          {
            addr = listenAddress;
            port = peers.dashboardPort;
          }
        ];
        root = dashboard;
        locations."/".tryFiles = "$uri $uri.html $uri/ /index.html";
      };
    };

    services.traefik = {
      staticConfigOptions.entryPoints.websecure.allowACMEByPass = true;

      dynamicConfigOptions.tcp = {
        routers.netbird-proxy = {
          rule = "HostSNIRegexp(`^.+\\.${lib.escapeRegex peers.host}$`)";
          entryPoints = [ "websecure" ];
          service = "netbird-proxy";
          priority = 1000;
          tls.passthrough = true;
        };

        services.netbird-proxy.loadBalancer = {
          servers = [ { address = "${listenAddress}:${toString proxyListenPort}"; } ];
          serversTransport = "netbird-proxy-proxy-protocol";
        };

        serversTransports.netbird-proxy-proxy-protocol.proxyProtocol.version = 2;
      };
    };

    networking.firewall.allowedUDPPorts = [
      peers.stunPort
      proxyWireGuardPort
    ];

    galaxy = {
      backup.paths = [
        stateDir
        proxyStateDir
      ];
      proxy.rules = [
        (grpcRule "netbird-grpc-signal" "/signalexchange.SignalExchange/")
        (grpcRule "netbird-grpc-management" "/management.ManagementService/")
        (grpcRule "netbird-grpc-proxy" "/management.ProxyService/")
        (backendRule "netbird-backend-relay" "/relay")
        (backendRule "netbird-backend-ws" "/ws-proxy/")
        (backendRule "netbird-backend-api" "/api")
        (backendRule "netbird-backend-oauth2" "/oauth2")
        {
          name = "netbird-dashboard";
          priority = 1;
          from.host = peers.host;
          to.http = "http://${listenAddress}:${toString peers.dashboardPort}";
        }
      ];
    };
  };
}
