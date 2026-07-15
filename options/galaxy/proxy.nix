{ config, lib, ... }:

let
  inherit (config.galaxy) domain peers proxy;

  meshSourceRanges = [
    # Tailscale and the current NetBird network both use addresses from the
    # shared carrier-grade NAT range. Keep Tailscale IPv6 during migration.
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

                meshOnly = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Only allow clients from the private mesh networks.";
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

          compress = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Compress responses served by this route.";
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
      hasMeshOnlyRules = lib.any (rule: rule.from.meshOnly) rules;
      hasPrivateRules = lib.any (rule: rule.from.private) rules;
      hasCompressedRules = lib.any (rule: rule.compress) rules;
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
                middlewares = lib.optional rule.from.meshOnly "mesh-only" ++ lib.optional rule.compress "compress";
              in
              {
                inherit (rule) name;
                value = {
                  rule = lib.concatStringsSep " && " matchers;
                  entryPoints = [ (if rule.from.private then "netbirdPrivate" else "websecure") ];
                  service = rule.name;
                }
                // lib.optionalAttrs (middlewares != [ ]) {
                  inherit middlewares;
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

          middlewares =
            lib.optionalAttrs hasMeshOnlyRules {
              mesh-only.ipAllowList.sourceRange = meshSourceRanges;
            }
            // lib.optionalAttrs hasCompressedRules { compress.compress = { }; };
        };
      };

      users.users.traefik.extraGroups = [ "acme" ];

      assertions = map (rule: {
        assertion = !(rule.from.private && rule.from.meshOnly);
        message = "Proxy rule ${rule.name} cannot be both private and meshOnly.";
      }) rules;

      networking.firewall.allowedTCPPorts = [
        httpPort
        httpsPort
      ];
    }
  );
}
