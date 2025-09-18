{
  inputs,
  config,
  pkgs-unstable,
  ...
}:

let
  system = pkgs-unstable.stdenv.hostPlatform.system;
  domain = config.universe.domain;

  tuwunelPort = 6167;
  traefikEntryPointName = "matrix";
  traefikEntryPointPort = 8448;
  matrixHost = "matrix.${domain}";
  matrixServerName = domain;
  elementCallHost = "meet.${domain}";
  elementCallUpstream = "https://call.element.io";
  matrixFocusUrl = "https://livekit-jwt.call.matrix.org";
in
{
  imports = [
    (pkgs-unstable.path + "/nixos/modules/services/matrix/tuwunel.nix")
  ];

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
        well_known = {
          client = "https://${matrixHost}";
          server = "${matrixHost}:${toString traefikEntryPointPort}";
          "org.matrix.msc4143.rtc_foci" = [
            {
              type = "livekit";
              livekit_service_url = matrixFocusUrl;
            }
          ];
        };
      };
    };
  };

  sops.secrets."planets/pollux/tuwunel/registration_token" = {
    owner = config.services.matrix-tuwunel.user;
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

  networking.firewall.allowedTCPPorts = [ traefikEntryPointPort ];
}
