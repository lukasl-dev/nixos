{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.netbird.server;
  json = pkgs.formats.json { };

  stateDir = cfg.dataDir;
  runtimeConfig = "/run/netbird/config.yaml";
  baseUrl = cfg.publicUrl;

  recursiveUpdateMany = lib.foldl' lib.recursiveUpdate { };

  defaultServerConfig = {
    server = {
      listenAddress = "${cfg.listenAddress}:${toString cfg.port}";
      exposedAddress = "${baseUrl}:443";
      stunPorts = [ cfg.stunPort ];
      metricsPort = cfg.metricsPort;
      healthcheckAddress = "${cfg.healthcheckListenAddress}:${toString cfg.healthcheckPort}";
      logLevel = cfg.logLevel;
      logFile = "console";
      dataDir = stateDir;

      auth = {
        issuer = "${baseUrl}/oauth2";
        localAuthDisabled = false;
        signKeyRefreshEnabled = true;
        dashboardRedirectURIs = [
          "${baseUrl}/nb-auth"
          "${baseUrl}/nb-silent-auth"
        ];
        cliRedirectURIs = [
          "http://localhost:53000/"
        ];
      };

      reverseProxy = cfg.reverseProxy;

      store = {
        engine = "sqlite";
        dsn = "";
      };
    };
  };

  combinedConfig = recursiveUpdateMany [
    defaultServerConfig
    cfg.settings
  ];

  baseConfigFile = pkgs.writeText "netbird-combined-config-base.json" (
    builtins.toJSON combinedConfig
  );

  configGenerator = pkgs.writers.writePython3 "netbird-combined-config" { } ''
    import json
    import os
    import sys

    base_config, output = sys.argv[1], sys.argv[2]

    with open(base_config, "r", encoding="utf-8") as f:
        config = json.load(f)

    credentials_dir = os.environ.get("CREDENTIALS_DIRECTORY", "")

    def read_file(path):
        if not path or not os.path.exists(path):
            return None
        with open(path, "r", encoding="utf-8") as f:
            return f.read().strip()

    def credential(name):
        if not credentials_dir:
            return None
        return read_file(os.path.join(credentials_dir, name))

    def credential_or_file(name, env_name):
        return credential(name) or read_file(os.environ.get(env_name))

    server = config.setdefault("server", {})
    auth = server.setdefault("auth", {})
    store = server.setdefault("store", {})

    value = credential_or_file("authSecret", "NETBIRD_AUTH_SECRET_FILE")
    if value:
        server["authSecret"] = value

    value = credential_or_file("storeEncryptionKey", "NETBIRD_STORE_ENCRYPTION_KEY_FILE")
    if value:
        store["encryptionKey"] = value

    owner_email = credential("ownerEmail")
    owner_password = credential("ownerPassword")
    if owner_email and owner_password:
        auth["owner"] = {
            "email": owner_email,
            "password": owner_password,
        }

    os.makedirs(os.path.dirname(output), exist_ok=True)
    tmp = output + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        # YAML parsers accept JSON; keeping JSON avoids a runtime PyYAML dependency.
        json.dump(config, f, indent=2)
        f.write("\n")
    os.chmod(tmp, 0o600)
    os.replace(tmp, output)
  '';

  generatedSecretsDir = "${stateDir}/secrets";
  generatedAuthSecretFile = "${generatedSecretsDir}/auth-secret";
  generatedStoreEncryptionKeyFile = "${generatedSecretsDir}/store-encryption-key";

  secretFile = optionFile: generatedFile: if optionFile != null then optionFile else generatedFile;

  dashboardSettings = {
    NETBIRD_MGMT_API_ENDPOINT = baseUrl;
    NETBIRD_MGMT_GRPC_API_ENDPOINT = baseUrl;
    AUTH_AUDIENCE = "netbird-dashboard";
    AUTH_CLIENT_ID = "netbird-dashboard";
    AUTH_CLIENT_SECRET = "";
    AUTH_AUTHORITY = "${baseUrl}/oauth2";
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
  }
  // cfg.dashboardSettings;

  toStringEnv = value: if lib.isBool value then lib.boolToString value else toString value;

  dashboard =
    pkgs.runCommand "netbird-dashboard-${cfg.domain}"
      {
        nativeBuildInputs = [ pkgs.gettext ];
        env = (lib.mapAttrs (_: toStringEnv) dashboardSettings) // {
          ENV_STR = lib.concatStringsSep " " (map (name: "$${name}") (lib.attrNames dashboardSettings));
        };
      }
      ''
        cp -R ${cfg.dashboardPackage} build
        chmod -R u+w build

        oidc_trusted_domains="build/OidcTrustedDomains.js"
        if [ -e "$oidc_trusted_domains.tmpl" ]; then
          envsubst "$ENV_STR" < "$oidc_trusted_domains.tmpl" > "$oidc_trusted_domains"
        fi

        for file in $(grep -R -l 'AUTH_SUPPORTED_SCOPES\|NETBIRD_MGMT_API_ENDPOINT\|AUTH_AUTHORITY' build || true); do
          cp "$file" "$file.copy"
          envsubst "$ENV_STR" < "$file.copy" > "$file"
          rm "$file.copy"
        done

        cp -R build $out
      '';

  credential = name: file: lib.optional (file != null) "${name}:${file}";

  serviceConfigFile = if cfg.configFile != null then cfg.configFile else runtimeConfig;
in
{
  disabledModules = [
    "services/networking/netbird/server.nix"
  ];

  options.services.netbird.server = {
    enable = lib.mkEnableOption "combined NetBird self-hosted server";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.netbird-server;
      defaultText = lib.literalExpression "pkgs.netbird-server";
      description = "Package providing the combined netbird-server binary.";
    };

    dashboardPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.unstable.netbird-dashboard or pkgs.netbird-dashboard;
      defaultText = lib.literalExpression "pkgs.unstable.netbird-dashboard or pkgs.netbird-dashboard";
      description = "Static NetBird dashboard package to template and serve.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "netbird";
      description = "System user that runs netbird-server.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "netbird";
      description = "System group that runs netbird-server.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/netbird";
      description = "Persistent data directory.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      description = "Public hostname for the NetBird dashboard and combined backend.";
    };

    publicUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://${cfg.domain}";
      defaultText = lib.literalExpression ''"https://$${config.services.netbird.server.domain}"'';
      description = "Public URL without a trailing slash.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address for HTTP/gRPC/WebSocket backend traffic.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port for HTTP/gRPC/WebSocket backend traffic.";
    };

    dashboardListenAddress = lib.mkOption {
      type = lib.types.str;
      default = cfg.listenAddress;
      defaultText = lib.literalExpression "config.services.netbird.server.listenAddress";
      description = "Address for the local static dashboard server.";
    };

    dashboardPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for the local static dashboard server.";
    };

    stunPort = lib.mkOption {
      type = lib.types.port;
      default = 3478;
      description = "UDP STUN port served directly by netbird-server.";
    };

    metricsPort = lib.mkOption {
      type = lib.types.port;
      default = 9090;
      description = "Metrics port configured for netbird-server.";
    };

    healthcheckListenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Healthcheck listen address configured for netbird-server.";
    };

    healthcheckPort = lib.mkOption {
      type = lib.types.port;
      default = 9000;
      description = "Healthcheck port configured for netbird-server.";
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

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the UDP STUN port in the firewall.";
    };

    enableDashboard = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Serve a templated static dashboard on dashboardListenAddress:dashboardPort.";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/etc/netbird/config.yaml";
      description = "Existing config.yaml to use instead of generating one from options and credentials.";
    };

    generateSecrets = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Generate missing auth/store secrets under dataDir/secrets when no corresponding
        secret file is configured. Disable this if secrets must come only from agenix,
        sops-nix, or systemd credentials.
      '';
    };

    settings = lib.mkOption {
      type = json.type;
      default = { };
      description = ''
        Extra public combined-server config merged into the generated config.
        Do not put secrets here unless you accept them being copied to the Nix store;
        use the *File options instead.
      '';
    };

    reverseProxy = lib.mkOption {
      type = json.type;
      default = { };
      description = "server.reverseProxy settings for the generated combined-server config.";
    };

    dashboardSettings = lib.mkOption {
      type = json.type;
      default = { };
      description = "Extra public environment substitutions for the static dashboard.";
    };

    authSecretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Secret file loaded as a systemd credential for server.authSecret.";
    };

    storeEncryptionKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Secret file loaded as a systemd credential for server.store.encryptionKey.";
    };

    ownerEmailFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional secret file for the bootstrap owner/admin email.";
    };

    ownerPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional secret file for the bootstrap owner/admin password.";
    };

    backendUrl = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Local HTTP/WebSocket backend URL.";
    };

    backendH2cUrl = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Local h2c backend URL for gRPC proxying.";
    };

    dashboardUrl = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Local dashboard URL.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.configFile != null
          || cfg.generateSecrets
          || cfg.authSecretFile != null
          || ((cfg.settings.server.authSecret or "") != "");
        message = "services.netbird.server.authSecretFile is required when generateSecrets is disabled.";
      }
      {
        assertion =
          cfg.configFile != null
          || cfg.generateSecrets
          || cfg.storeEncryptionKeyFile != null
          || ((cfg.settings.server.store.encryptionKey or "") != "");
        message = "services.netbird.server.storeEncryptionKeyFile is required when generateSecrets is disabled.";
      }
      {
        assertion = (cfg.ownerEmailFile == null) == (cfg.ownerPasswordFile == null);
        message = "Set both services.netbird.server.ownerEmailFile and ownerPasswordFile, or neither.";
      }
    ];

    services.netbird.server = {
      backendUrl = "http://${cfg.listenAddress}:${toString cfg.port}";
      backendH2cUrl = "h2c://${cfg.listenAddress}:${toString cfg.port}";
      dashboardUrl = "http://${cfg.dashboardListenAddress}:${toString cfg.dashboardPort}";
    };

    users = {
      groups.${cfg.group} = { };
      users.${cfg.user} = {
        isSystemUser = true;
        group = cfg.group;
        home = stateDir;
      };
    };

    environment.systemPackages = [ cfg.package ];

    systemd.tmpfiles.rules = [
      "d /etc/netbird 0750 root ${cfg.group} - -"
      "d ${stateDir} 0750 ${cfg.user} ${cfg.group} - -"
    ];

    systemd.services.netbird-server = {
      description = "NetBird combined self-hosted server";
      documentation = [
        "https://docs.netbird.io/selfhosted/selfhosted-quickstart"
        "https://docs.netbird.io/selfhosted/external-reverse-proxy"
      ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      path = [
        pkgs.coreutils
        pkgs.openssl
      ];

      preStart = lib.mkIf (cfg.configFile == null) ''
        ${lib.optionalString cfg.generateSecrets ''
          install -d -m 0700 ${generatedSecretsDir}

          ${lib.optionalString (cfg.authSecretFile == null) ''
            if [ ! -s ${generatedAuthSecretFile} ]; then
              umask 077
              openssl rand -base64 32 > ${generatedAuthSecretFile}.tmp
              mv ${generatedAuthSecretFile}.tmp ${generatedAuthSecretFile}
            fi
          ''}

          ${lib.optionalString (cfg.storeEncryptionKeyFile == null) ''
            if [ ! -s ${generatedStoreEncryptionKeyFile} ]; then
              umask 077
              openssl rand -base64 32 > ${generatedStoreEncryptionKeyFile}.tmp
              mv ${generatedStoreEncryptionKeyFile}.tmp ${generatedStoreEncryptionKeyFile}
            fi
          ''}
        ''}

        NETBIRD_AUTH_SECRET_FILE=${lib.escapeShellArg (secretFile cfg.authSecretFile generatedAuthSecretFile)} \
        NETBIRD_STORE_ENCRYPTION_KEY_FILE=${lib.escapeShellArg (secretFile cfg.storeEncryptionKeyFile generatedStoreEncryptionKeyFile)} \
          ${configGenerator} ${baseConfigFile} ${runtimeConfig}
      '';

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        StateDirectory = lib.mkIf (stateDir == "/var/lib/netbird") "netbird";
        RuntimeDirectory = "netbird";
        RuntimeDirectoryMode = "0750";
        WorkingDirectory = stateDir;
        ExecStart = "${lib.getExe cfg.package} --config ${serviceConfigFile}";
        Restart = "on-failure";
        RestartSec = "5s";
        LoadCredential = lib.concatLists [
          (credential "authSecret" cfg.authSecretFile)
          (credential "storeEncryptionKey" cfg.storeEncryptionKeyFile)
          (credential "ownerEmail" cfg.ownerEmailFile)
          (credential "ownerPassword" cfg.ownerPasswordFile)
        ];

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [
          stateDir
          "/run/netbird"
        ];
      };
    };

    services.nginx = lib.mkIf cfg.enableDashboard {
      enable = true;
      virtualHosts."netbird-dashboard-${cfg.domain}" = {
        listen = [
          {
            addr = cfg.dashboardListenAddress;
            port = cfg.dashboardPort;
          }
        ];
        root = dashboard;
        locations."/".tryFiles = "$uri $uri.html $uri/ /index.html";
        locations."/404.html".extraConfig = "internal;";
        extraConfig = ''
          error_page 404 /404.html;
        '';
      };
    };

    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [ cfg.stunPort ];
  };
}
