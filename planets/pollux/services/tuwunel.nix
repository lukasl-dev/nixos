{ config, pkgs-unstable, ... }:

let
  domain = config.universe.domain;

  tuwunelPort = 6167;
  traefikEntryPointName = "matrix";
  traefikEntryPointPort = 8448;
  matrixHost = "matrix.${domain}";
in
{
  imports = [
    (pkgs-unstable.path + "/nixos/modules/services/matrix/tuwunel.nix")
  ];

  services.matrix-tuwunel = {
    enable = true;
    package = pkgs-unstable.matrix-tuwunel;
    settings = {
      global = {
        server_name = matrixHost;
        address = [ "127.0.0.1" ];
        port = [ tuwunelPort ];
        allow_registration = true;
        registration_token_file = config.sops.secrets."planets/pollux/tuwunel/registration_token".path;
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
        routers.tuwunel = {
          rule = "Host(`${matrixHost}`)";
          entryPoints = [ "websecure" ];
          service = "tuwunel";
        };

        services.tuwunel = {
          loadBalancer.servers = [
            {
              url = "http://127.0.0.1:${toString tuwunelPort}";
            }
          ];
        };
      };

      tcp = {
        routers.tuwunel = {
          rule = "HostSNI(`${matrixHost}`)";
          entryPoints = [ traefikEntryPointName ];
          service = "tuwunel-tcp";
          tls = { };
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
