{ config, lib, ... }:

let
  inherit (config.planet.hosting) proxy;

  httpPort = 80;
  httpsPort = 443;
in
{
  options.planet.hosting.proxy = {
    enable = lib.mkEnableOption "Reverse proxy";
    rules = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            ingress = {
              host = lib.mkOption {
                type = lib.types.str;
              };

              http = {
                path = {
                  exact = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                  };

                  prefix = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                  };
                };
              };
            };

            upstream = {
              http = {
                url = lib.mkOption {
                  type = lib.types.str;
                };
              };
            };
          };
        }
      );
      default = { };
      description = "Reverse proxy rules keyed by their unique names.";
    };
  };

  config = lib.mkIf proxy.enable {
    assertions = lib.mapAttrsToList (name: rule: {
      assertion =
        let
          inherit (rule.ingress.http.path) exact prefix;
        in
        exact == null || prefix == null;
      message = ''
        Proxy rule ${name} cannot match both an exact path and a path prefix.
      '';
    }) proxy.rules;

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

            transport = {
              lifeCycle.requestAcceptGraceTimeout = "30s";
              respondingTimeouts = {
                readTimeout = "0s";
                writeTimeout = "0s";
                idleTimeout = "600s";
              };
            };

            http.tls = { };
          };
        };
      };

      dynamicConfigOptions.http = {
        routers = lib.mapAttrs (
          name: rule:
          let
            inherit (rule.ingress) host;
            inherit (rule.ingress.http.path) exact prefix;

            matchers = [
              "Host(`${host}`)"
            ]
            ++ lib.optional (exact != null) "Path(`${exact}`)"
            ++ lib.optional (prefix != null) "PathPrefix(`${prefix}`)";
          in
          {
            rule = lib.concatStringsSep " && " matchers;
            entryPoints = [ "websecure" ];
            service = name;
          }
        ) proxy.rules;

        services = lib.mapAttrs (_: rule: {
          loadBalancer = {
            passHostHeader = true;
            servers = [ { inherit (rule.upstream.http) url; } ];
          };
        }) proxy.rules;
      };
    };

    networking.firewall.allowedTCPPorts = [
      httpPort
      httpsPort
    ];
  };
}
