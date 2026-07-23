{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet.hosting) proxy;

  secret =
    name:
    atlas.secrets.universe [
      "acme"
      name
    ];

  cfEmail = secret "cf_email";
  cfApiKey = secret "cf_api_key";
  cfEnv = secret "env";

  hosts = lib.unique (lib.mapAttrsToList (_: rule: rule.ingress.host) proxy.rules);
in
{
  config = lib.mkIf proxy.enable {
    age.secrets = {
      ${cfEmail} = {
        rekeyFile = ../../.. + "/secrets/${cfEmail}.age";
        intermediary = true;
      };

      ${cfApiKey} = {
        rekeyFile = ../../.. + "/secrets/${cfApiKey}.age";
        intermediary = true;
      };

      ${cfEnv} = {
        rekeyFile = ../../.. + "/secrets/${cfEnv}.age";
        generator = {
          dependencies = {
            cf_email = age.secrets.${cfEmail};
            cf_api_key = age.secrets.${cfApiKey};
          };
          script =
            { decrypt, deps, ... }:
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

    security.acme = {
      acceptTerms = true;
      defaults = {
        email = "contact@lukasl.dev";
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
      };
      certs = lib.genAttrs hosts (_: {
        environmentFile = age.secrets.${cfEnv}.path;
        reloadServices = [ "traefik.service" ];
      });
    };

    services.traefik.dynamicConfigOptions.tls.certificates = map (host: {
      certFile = "/var/lib/acme/${host}/fullchain.pem";
      keyFile = "/var/lib/acme/${host}/key.pem";
    }) hosts;

    users.users.traefik.extraGroups = [ "acme" ];

    systemd.services.traefik =
      let
        services = map (host: "acme-${host}.service") hosts;
      in
      {
        wants = services;
        after = services;
      };
  };
}
