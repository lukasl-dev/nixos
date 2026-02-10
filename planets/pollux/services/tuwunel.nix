{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (config.universe) domain;

  tuwunelPort = 6167;

  traefikEntryPointName = "matrix";
  traefikEntryPointPort = 8448;

  matrixHost = "matrix.${domain}";
  matrixClientUrl = "https://${matrixHost}";
  matrixWellKnownServer = "${matrixHost}:${toString traefikEntryPointPort}";
  matrixServerName = domain;

  elementCallHost = "call.${domain}";
  elementCallPort = 8765;
  elementCallUpstream = "http://127.0.0.1:${toString elementCallPort}";
  matrixRtcJwtUrl = "https://${elementCallHost}/livekit/jwt";
  turnHost = "turn.${domain}";
  turnSecretFile = config.sops.secrets."planets/pollux/tuwunel/turn_secret".path;
  elementCallConfigJson = builtins.toJSON {
    default_server_config = {
      "m.homeserver" = {
        "base_url" = matrixClientUrl;
        "server_name" = matrixServerName;
      };
    };
    livekit.livekit_service_url = matrixRtcJwtUrl;
  };

  livekitApiPort = 8080;
  livekitSfuPort = 7880;
in
{
  # imports = [
  #   (pkgs-unstable.path + "/nixos/modules/services/matrix/tuwunel.nix")
  # ];

  systemd.services = {
    livekit.serviceConfig.Restart = lib.mkForce "always";
    lk-jwt-service = {
      serviceConfig.Restart = lib.mkForce "always";
      environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = matrixServerName;
    };
  };

  services.matrix-tuwunel = {
    enable = true;
    package = inputs.tuwunel.packages.${system}.default;
    settings = {
      global = {
        server_name = matrixServerName;
        address = [ "127.0.0.1" ];
        port = [ tuwunelPort ];
        allow_registration = true;
        registration_token_file = config.sops.secrets."planets/pollux/tuwunel/registration_token".path;
        turn_uris = [
          "turn:${turnHost}?transport=udp"
          "turn:${turnHost}?transport=tcp"
          "turns:${turnHost}?transport=tcp"
        ];
        turn_secret_file = turnSecretFile;
        well_known = {
          client = matrixClientUrl;
          server = matrixWellKnownServer;
          rtc_transports = [
            {
              type = "livekit";
              livekit_service_url = matrixRtcJwtUrl;
            }
          ];
        };
        url_preview_domain_contains_allowlist = [ "*" ];
        # url_preview_domain_explicit_allowlist = [
        #   "youtube.com"
        #   "www.youtube.com"
        #   "m.youtube.com"
        #   "consent.youtube.com"
        #   "youtu.be"
        #   "ytimg.com"
        #   "github.com"
        #   "wikipedia.org"
        # ];
        url_preview_check_root_domain = true;
      };
    };
  };

  services.livekit = {
    enable = true;
    keyFile = config.sops.secrets."planets/pollux/livekit/keys".path;
    openFirewall = true;
    settings = {
      port = livekitSfuPort;
      room.auto_create = false;
      rtc = {
        port_range_start = 50000;
        port_range_end = 51000;
        use_external_ip = true;
        tcp_port = 7881;
      };
    };
  };

  services.lk-jwt-service = {
    enable = true;
    livekitUrl = "wss://${elementCallHost}/livekit/sfu";
    keyFile = config.services.livekit.keyFile;
    port = livekitApiPort;
  };

  services.coturn = {
    enable = true;
    realm = domain;
    use-auth-secret = true;
    static-auth-secret-file = turnSecretFile;
    no-cli = true;
    cert = "/var/lib/acme/${domain}/fullchain.pem";
    pkey = "/var/lib/acme/${domain}/key.pem";
    min-port = 52000;
    max-port = 55000;
    extraConfig = ''
      fingerprint
      no-multicast-peers
    '';
  };

  users.users.turnserver.extraGroups = [ "acme" ];

  services.nginx.virtualHosts.${elementCallHost} = {
    enableACME = false;
    listen = [
      {
        addr = "127.0.0.1";
        port = elementCallPort;
      }
    ];
    root = pkgs.unstable.element-call;
    # index = [ "index.html" ];
    extraConfig = ''
      autoindex off;
    '';
    locations = {
      "/" = {
        extraConfig = ''
          try_files $uri /index.html;
        '';
      };

      "= /config.json" = {
        extraConfig = ''
          default_type application/json;
          return 200 '${elementCallConfigJson}';
        '';
      };

      "^~ /livekit/sfu/" = {
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_send_timeout 300s;
          proxy_read_timeout 300s;
          proxy_buffering off;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_pass http://127.0.0.1:${toString livekitSfuPort}/;
        '';
      };

      "= /livekit/sfu" = {
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_send_timeout 300s;
          proxy_read_timeout 300s;
          proxy_buffering off;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_pass http://127.0.0.1:${toString livekitSfuPort}/;
        '';
      };

      "^~ /livekit/jwt/" = {
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_pass http://127.0.0.1:${toString livekitApiPort}/;
        '';
      };
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  sops.secrets."planets/pollux/tuwunel/registration_token" = {
    owner = config.services.matrix-tuwunel.user;
  };

  sops.secrets."planets/pollux/livekit/keys" = {
    mode = "0400";
  };

  sops.secrets."planets/pollux/tuwunel/turn_secret" = {
    mode = "0440";
    owner = "turnserver";
    group = config.services.matrix-tuwunel.group;
  };

  services.traefik = {
    staticConfigOptions.entryPoints.${traefikEntryPointName} = {
      address = ":${toString traefikEntryPointPort}";
    };

    dynamicConfigOptions = {
      http = {
        routers = {
          tuwunel = {
            rule = "Host(`${matrixHost}`)";
            entryPoints = [ "websecure" ];
            service = "tuwunel";
          };

          tuwunel-well-known = {
            rule = "Host(`${matrixServerName}`) && PathPrefix(`/.well-known/matrix`)";
            entryPoints = [ "websecure" ];
            service = "tuwunel";
            priority = 100;
          };

          element-call = {
            rule = "Host(`${elementCallHost}`)";
            entryPoints = [ "websecure" ];
            service = "element-call";
          };
        };

        services = {
          tuwunel = {
            loadBalancer.servers = [
              {
                url = "http://127.0.0.1:${toString tuwunelPort}";
              }
            ];
          };

          element-call = {
            loadBalancer = {
              passHostHeader = false;
              servers = [
                {
                  url = elementCallUpstream;
                }
              ];
            };
          };

        };
      };

      tcp = {
        routers = {
          tuwunel = {
            rule = "HostSNI(`${matrixHost}`)";
            entryPoints = [ traefikEntryPointName ];
            service = "tuwunel-tcp";
            tls = { };
          };

          tuwunel-apex = {
            rule = "HostSNI(`${matrixServerName}`)";
            entryPoints = [ traefikEntryPointName ];
            service = "tuwunel-tcp";
            tls = { };
          };
        };

        services."tuwunel-tcp" = {
          loadBalancer.servers = [
            {
              address = "127.0.0.1:${toString tuwunelPort}";
            }
          ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    traefikEntryPointPort
    7881
    3478
    5349
  ];

  networking.firewall.allowedUDPPorts = [
    3478
  ];

  networking.firewall.allowedUDPPortRanges = [
    {
      from = 52000;
      to = 55000;
    }
  ];
}
