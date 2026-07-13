{ config, lib, ... }:

let
  inherit (config.galaxy) domain peers proxy;

  tailscaleSourceRanges = [
    "100.64.0.0/10"
    "fd7a:115c:a1e0::/48"
  ];

  rules = proxy.rules;
in
{
  options.galaxy.proxy.rules = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
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

                tailscaleOnly = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Only allow clients from the Tailscale network.";
                };

                private = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = ''
                    Expose this route only on the loopback NetBird proxy entrypoint.
                    Its private hostname is <rule name>.${peers.host}.
                  '';
                };
              };
            };
            default = { };
          };

          priority = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
          };

          to.http = lib.mkOption {
            type = lib.types.str;
          };
        };
      }
    );
    default = [ ];
    description = "Reverse proxy rules for galaxy services.";
  };

  config = lib.mkIf (rules != [ ]) (
    let
      httpPort = 80;
      httpsPort = 443;
      hasTailscaleOnlyRules = lib.any (rule: rule.from.tailscaleOnly) rules;
      hasPrivateRules = lib.any (rule: rule.from.private) rules;
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
          }
          // lib.optionalAttrs hasPrivateRules {
            netbirdPrivate.address = "127.0.0.1:8444";
          };
        };

        dynamicConfigOptions.http = {
          routers = lib.listToAttrs (
            map (
              rule:
              let
                host =
                  if rule.from.private then
                    "${rule.name}.${peers.host}"
                  else if rule.from.host != null then
                    rule.from.host
                  else
                    "${rule.name}.${domain}";
                matchers = [
                  "Host(`${host}`)"
                ]
                ++ lib.optional (rule.from.path != null) "Path(`${rule.from.path}`)"
                ++ lib.optional (rule.from.pathPrefix != null) "PathPrefix(`${rule.from.pathPrefix}`)";
              in
              {
                inherit (rule) name;
                value = {
                  rule = lib.concatStringsSep " && " matchers;
                  entryPoints = [ (if rule.from.private then "netbirdPrivate" else "websecure") ];
                  service = rule.name;
                }
                // lib.optionalAttrs rule.from.tailscaleOnly {
                  middlewares = [ "tailscale-only" ];
                }
                // lib.optionalAttrs (rule.priority != null) {
                  inherit (rule) priority;
                };
              }
            ) rules
          );

          services = lib.listToAttrs (
            map (rule: {
              inherit (rule) name;
              value.loadBalancer = {
                passHostHeader = true;
                servers = [ { url = rule.to.http; } ];
              };
            }) rules
          );

          middlewares = lib.mkIf hasTailscaleOnlyRules {
            tailscale-only.ipAllowList.sourceRange = tailscaleSourceRanges;
          };
        };
      };

      users.users.traefik.extraGroups = [ "acme" ];

      assertions = map (rule: {
        assertion = !(rule.from.private && rule.from.tailscaleOnly);
        message = "Proxy rule ${rule.name} cannot be both private and tailscaleOnly.";
      }) rules;

      networking.firewall.allowedTCPPorts = [
        httpPort
        httpsPort
      ];
    }
  );
}
