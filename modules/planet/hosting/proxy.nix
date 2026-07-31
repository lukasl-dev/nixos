{
  config,
  lib,
  ...
}:

let
  inherit (config) planet;
  inherit (planet.hosting) proxy;

  httpPort = 80;
  httpsPort = 443;

  ruleFor =
    host: rule:
    let
      inherit (rule.ingress.http.path) exact prefix;

      matchers = [
        "Host(`${host}`)"
      ]
      ++ lib.optional (exact != null) "Path(`${exact}`)"
      ++ lib.optional (prefix != null) "PathPrefix(`${prefix}`)";
    in
    lib.concatStringsSep " && " matchers;

  routerFor =
    {
      entryPoint,
      host,
      name,
      rule,
    }:
    {
      rule = ruleFor host rule;
      entryPoints = [ entryPoint ];
      service = name;
    };

  publicRouters = lib.mapAttrs (
    name: rule:
    routerFor {
      entryPoint = "websecure";
      host = rule.ingress.host;
      inherit name rule;
    }
  ) proxy.rules;

  redirectRouters = lib.mapAttrs' (
    name: rule:
    lib.nameValuePair "redirect-${name}" (
      routerFor {
        entryPoint = "web";
        host = rule.ingress.host;
        inherit name rule;
      }
      // {
        middlewares = [ "redirect-to-https" ];
      }
    )
  ) proxy.rules;

  localRouters = lib.mapAttrs' (
    name: rule:
    lib.nameValuePair "local-${name}" (routerFor {
      entryPoint = "web";
      host = "${name}.${planet.name}.local";
      inherit name rule;
    })
  ) proxy.rules;

  homeArpaRouters = lib.mapAttrs' (
    name: rule:
    lib.nameValuePair "local-home-arpa-${name}" (routerFor {
      entryPoint = "web";
      host = "${name}.${planet.name}.home.arpa";
      inherit name rule;
    })
  ) proxy.rules;
in
{
  options.planet.hosting.proxy = {
    enable = lib.mkEnableOption "Reverse proxy";

    local = lib.mkEnableOption "local HTTP routes with automatic mDNS aliases";

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
          web.address = ":${toString httpPort}";
        }
        // lib.optionalAttrs (!proxy.local) {
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
        routers =
          lib.optionalAttrs (!proxy.local) (publicRouters // redirectRouters)
          // lib.optionalAttrs proxy.local (localRouters // homeArpaRouters);

        services = lib.mapAttrs (_: rule: {
          loadBalancer = {
            passHostHeader = true;
            servers = [ { inherit (rule.upstream.http) url; } ];
          };
        }) proxy.rules;
      }
      // lib.optionalAttrs (!proxy.local) {
        middlewares.redirect-to-https.redirectScheme = {
          scheme = "https";
          permanent = true;
        };
      };
    };

    planet.networking.dns = lib.mkIf proxy.local {
      discoverable = true;
      aliases = builtins.attrNames proxy.rules;
    };

    networking.firewall.allowedTCPPorts = [
      httpPort
    ]
    ++ lib.optional (!proxy.local) httpsPort;
  };
}
