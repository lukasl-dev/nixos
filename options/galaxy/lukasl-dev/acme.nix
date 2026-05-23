{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev) domain;

  cf_email = "galaxy/lukasl-dev/acme/cf_email";
  cf_api_key = "galaxy/lukasl-dev/acme/cf_global_api_key";
  cf_env = "galaxy/lukasl-dev/acme/env";
in
{
  config = lib.mkIf config.galaxy.acme.enable {
    age.secrets = {
      ${cf_email} = {
        rekeyFile = ../../../secrets/galaxy/lukasl-dev/acme/cf_email.age;
        intermediary = true;
      };

      ${cf_api_key} = {
        rekeyFile = ../../../secrets/galaxy/lukasl-dev/acme/cf_api_key.age;
        intermediary = true;
      };

      ${cf_env} = {
        rekeyFile = ../../../secrets/galaxy/lukasl-dev/acme/env.age;
        generator = {
          dependencies = {
            cf_email = age.secrets.${cf_email};
            cf_api_key = age.secrets.${cf_api_key};
          };
          script =
            { decrypt, deps, ... }:
            # bash
            ''
              cf_email="$(${decrypt} "${deps.cf_email.file}")"
              cf_api_key="$(${decrypt} "${deps.cf_api_key.file}")"

              cat <<EOF
              CLOUDFLARE_EMAIL=$cf_email
              CLOUDFLARE_API_KEY=cf_api_key
              EOF
            '';
        };
      };
    };

    galaxy.acme.domains.${domain}.environmentFile = age.secrets.${cf_env}.path;
  };
}
