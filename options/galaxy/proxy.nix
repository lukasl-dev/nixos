{ config, lib, ... }:

let
  inherit (config.galaxy) proxy;

  allRules = lib.flatten (
    lib.mapAttrsToList (
      domain: rules: map (rule: rule // { inherit domain; }) (lib.filter (r: r.type == "https") rules)
    ) proxy.rules
  );
in
{
  options.galaxy.proxy = {
    enable = lib.mkEnableOption "Enable reverse proxy";

    rules = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.listOf (
          lib.types.submodule {
            options = {
              type = lib.mkOption {
                type = lib.types.enum [ "https" ];
              };

              name = lib.mkOption {
                type = lib.types.str;
              };

              from = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    host = lib.mkOption {
                      type = lib.types.nullOr lib.types.str;
                      default = null;
                    };

                    path = lib.mkOption {
                      type = lib.types.nullOr lib.types.str;
                      default = null;
                    };

                    pathPrefix = lib.mkOption {
                      type = lib.types.nullOr lib.types.str;
                      default = null;
                    };
                  };
                };
                default = { };
              };

              priority = lib.mkOption {
                type = lib.types.nullOr lib.types.int;
                default = null;
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
        )
      );
      default = { };
      description = "Per-domain reverse proxy rules.";
    };
  };

  config = lib.mkIf proxy.enable (
    let
      httpPort = 80;
      httpsPort = 443;
    in
    {
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
          };
        };

        dynamicConfigOptions = {
          http = {
            routers = lib.listToAttrs (
              map (
                rule:
                let
                  host = if (rule.from.host != null) then rule.from.host else "${rule.name}.${rule.domain}";
                  matchers = [ "Host(`${host}`)" ]
                    ++ lib.optional (rule.from.path != null) "Path(`${rule.from.path}`)"
                    ++ lib.optional (rule.from.pathPrefix != null) "PathPrefix(`${rule.from.pathPrefix}`)";
                in
                {
                  inherit (rule) name;
                  value = {
                    rule = lib.concatStringsSep " && " matchers;
                    entryPoints = [ "websecure" ];
                    service = rule.name;
                  }
                  // lib.optionalAttrs (rule.priority != null) {
                    inherit (rule) priority;
                  };
                }
              ) allRules
            );

            services = lib.listToAttrs (
              map (rule: {
                inherit (rule) name;
                value = {
                  passHostHeader = true;
                  loadBalancer.servers = [
                    { url = rule.http.to; }
                  ];
                };
              }) allRules
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
