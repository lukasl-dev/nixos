{ config, lib, ... }:

let
  inherit (config.galaxy) proxy;

  httpsRules = lib.filter (rule: rule.type == "https") proxy.rules;
in
{
  options.galaxy.proxy = {
    enable = lib.mkEnableOption "Enable reverse proxy";

    rules = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            type = lib.mkOption {
              type = lib.types.enum [ "https" ];
            };

            name = lib.mkOption {
              type = lib.types.str;
            };

            http = lib.mkOption {
              type = lib.types.submodule {
                options = {
                  to = lib.mkOption {
                    type = lib.types.str;
                  };
                };
              };
            };
          };
        }
      );
      default = [ ];
      description = "Reverse proxy rules.";
    };
  };

  config = lib.mkIf proxy.enable (
    let
      httpPort = 80;
      httpsPort = 443;
    in
    {
      # TODO: acme

      services.traefik = {
        enable = true;

        staticConfigOptions = {
          api.dashboard = false;

          entryPoints = {
            web = {
              address = ":${toString httpPort}";
              http.redirections.entrypoint = {
                to = "websecure";
                scheme = "https";
              };
            };

            websecure = {
              address = ":${toString httpsPort}";
              http.tls = { };
              transport.respondingTimeouts = {
                readTimeout = "0s";
                writeTimeout = "0s";
                idleTimeout = "600s";
              };
            };

            # uptermd = {
            #   address = ":2222";
            # };
          };
        };

        dynamicConfigOptions = {
          http = {
            routers = lib.listToAttrs (
              map (rule: {
                inherit (rule) name;
                value = {
                  rule = "Host(`${rule.name}.lukasl.dev`)";
                  entryPoints = [ "websecure" ];
                  service = rule.name;
                };
              }) httpsRules
            );

            services = lib.listToAttrs (
              map (rule: {
                inherit (rule) name;
                value = {
                  loadBalancer.servers = [
                    { url = rule.http.to; }
                  ];
                };
              }) httpsRules
            );
          };
        };
      };

      users.users.traefik.extraGroups = [ "acme" ];

      networking.firewall.allowedTCPPorts = [
        httpPort
        httpsPort
        8080
      ];
    }
  );
}
