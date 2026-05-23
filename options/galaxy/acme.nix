{ config, lib, ... }:

let
  inherit (config.galaxy) acme proxy;

  hostEntries = lib.unique (
    lib.flatten (
      lib.mapAttrsToList (
        domain: rules:
        map (rule: {
          host = if rule.from != null then rule.from else "${rule.name}.${domain}";
          inherit domain;
        }) rules
      ) proxy.rules
    )
  );
in
{
  options.galaxy.acme = {
    enable = lib.mkEnableOption "Manage ACME certificates for all proxy rules";

    email = lib.mkOption {
      type = lib.types.str;
      description = "Contact email for ACME.";
    };

    dnsProvider = lib.mkOption {
      type = lib.types.str;
      default = "cloudflare";
      description = "DNS provider for ACME challenges.";
    };

    dnsResolver = lib.mkOption {
      type = lib.types.str;
      default = "1.1.1.1:53";
      description = "DNS resolver for ACME challenges.";
    };

    domains = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            environmentFile = lib.mkOption {
              type = lib.types.path;
              description = "Path to the environment file with DNS provider credentials.";
            };
          };
        }
      );
      default = { };
      description = "Per-domain ACME configuration.";
    };
  };

  config = lib.mkIf acme.enable {
    security.acme = {
      acceptTerms = true;
      defaults = {
        inherit (acme) email dnsProvider dnsResolver;
      };
      certs = lib.listToAttrs (
        map (
          { host, domain }:
          {
            name = host;
            value = {
              reloadServices = [ "traefik.service" ];
              inherit (acme.domains.${domain}) environmentFile;
            };
          }
        ) hostEntries
      );
    };

    services.traefik.dynamicConfigOptions.tls.certificates = map (
      { host }:
      {
        certFile = "/var/lib/acme/${host}/fullchain.pem";
        keyFile = "/var/lib/acme/${host}/key.pem";
      }
    ) hostEntries;
  };
}
