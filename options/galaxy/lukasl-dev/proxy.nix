{ config, lib, ... }:

let
  inherit (config.galaxy) proxy;
  inherit (config.galaxy.lukasl-dev) domain;

  httpsRules = lib.filter (rule: rule.type == "https") proxy.rules;
in
{
  options.galaxy.lukasl-dev = {
    proxy = {
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

              from = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
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
  };

  config = lib.mkIf proxy.enable {
    services.traefik.dynamicConfigOptions = {
      http = {
        routers = lib.listToAttrs (
          map (
            rule:
            let
              host = if (rule.from != null) then rule.from else "${rule.name}.${domain}";
            in
            {
              inherit (rule) name;
              value = {
                rule = "Host(`${host}`)";
                entryPoints = [ "websecure" ];
                service = rule.name;
              };
            }
          ) httpsRules
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
          }) httpsRules
        );
      };
    };
  };
}
