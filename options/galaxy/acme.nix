{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy) acme domain proxy;

  cfEmail = "galaxy/acme/cf_email";
  cfApiKey = "galaxy/acme/cf_global_api_key";
  cfEnv = "galaxy/acme/env";

  proxyHosts = lib.unique (
    map (rule: if rule.from.host != null then rule.from.host else "${rule.name}.${domain}") proxy.rules
  );
  allHosts = lib.unique (proxyHosts ++ lib.attrNames acme.extraCertificates);
  acmeServices = map (host: "acme-${host}.service") proxyHosts;
in
{
  options.galaxy.acme = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to manage ACME certificates for galaxy services.";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "contact@lukasl.dev";
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

    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "Environment file containing DNS provider credentials.";
    };

    extraCertificates = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.reloadServices = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Services to reload when this certificate is renewed.";
          };
        }
      );
      default = { };
      description = "Certificates needed by services not routed through the reverse proxy.";
    };
  };

  config = lib.mkMerge [
    {
      age.secrets = {
        ${cfEmail} = {
          rekeyFile = ../../secrets/galaxy/acme/cf_email.age;
          intermediary = true;
        };

        ${cfApiKey} = {
          rekeyFile = ../../secrets/galaxy/acme/cf_api_key.age;
          intermediary = true;
        };

        ${cfEnv} = {
          rekeyFile = ../../secrets/galaxy/acme/env.age;
          generator = {
            dependencies = {
              cf_email = age.secrets.${cfEmail};
              cf_api_key = age.secrets.${cfApiKey};
            };
            script =
              { decrypt, deps, ... }:
              # bash
              ''
                cf_email="$(${decrypt} "${deps.cf_email.file}")"
                cf_api_key="$(${decrypt} "${deps.cf_api_key.file}")"

                cat <<EOF
                CLOUDFLARE_EMAIL=$cf_email
                CLOUDFLARE_API_KEY=$cf_api_key
                EOF
              '';
          };
        };
      };

      galaxy.acme.environmentFile = age.secrets.${cfEnv}.path;
    }

    (lib.mkIf acme.enable {
      security.acme = {
        acceptTerms = true;
        defaults = {
          inherit (acme) email dnsProvider dnsResolver;
        };
        certs = lib.genAttrs allHosts (host: {
          inherit (acme) environmentFile;
          reloadServices =
            lib.optional (lib.elem host proxyHosts) "traefik.service"
            ++ (acme.extraCertificates.${host}.reloadServices or [ ]);
        });
      };

      services.traefik.dynamicConfigOptions.tls.certificates = map (host: {
        certFile = "/var/lib/acme/${host}/fullchain.pem";
        keyFile = "/var/lib/acme/${host}/key.pem";
      }) proxyHosts;

      systemd.services.traefik = {
        wants = acmeServices;
        after = acmeServices;
      };
    })
  ];
}
