{ config, lib, ... }:

let
  inherit (config.galaxy) acme proxy;

  proxyHosts = lib.unique (
    lib.flatten (
      lib.mapAttrsToList (
        domain: rules:
        map (rule: {
          host = if rule.from.host != null then rule.from.host else "${rule.name}.${domain}";
          inherit domain;
        }) rules
      ) proxy.rules
    )
  );

  extraHosts = lib.unique (
    lib.flatten (
      lib.mapAttrsToList (domain: cfg: map (host: { inherit host domain; }) cfg.hosts) acme.domains
    )
  );

  allHosts = proxyHosts ++ extraHosts;
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

            hosts = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Additional hosts needing certificates (e.g. mail, not routed through traefik).";
            };

            reloadServices = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Extra services to reload on certificate renewal for this domain.";
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
              reloadServices = [ "traefik.service" ] ++ acme.domains.${domain}.reloadServices;
              inherit (acme.domains.${domain}) environmentFile;
            };
          }
        ) allHosts
      );
    };

    services.traefik.dynamicConfigOptions.tls.certificates = map (
      { host, ... }:
      {
        certFile = "/var/lib/acme/${host}/fullchain.pem";
        keyFile = "/var/lib/acme/${host}/key.pem";
      }
    ) proxyHosts;
  };
}
