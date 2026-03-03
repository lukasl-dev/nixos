{ config, ... }:

let
  inherit (config.universe) domain;
in
{
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "contact@${domain}";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.templates."acme/env".path;
      dnsResolver = "1.1.1.1:53";
    };

    # TODO: remove this
    certs.${domain} = {
      inherit domain;
      extraDomainNames = [
        "*.${domain}"
        "*.pollux.${domain}"
      ];
      reloadServices = [
        "traefik.service"
        "maddy.service"
      ];
    };
  };

  sops = {
    secrets = {
      "universe/cloudflare/email" = { };
      "universe/cloudflare/account_id" = { };
      "universe/cloudflare/global_api_key" = { };
    };

    templates."acme/env".content = ''
      CLOUDFLARE_EMAIL=${config.sops.placeholder."universe/cloudflare/email"}
      CLOUDFLARE_API_KEY=${config.sops.placeholder."universe/cloudflare/global_api_key"}
    '';
  };
}
