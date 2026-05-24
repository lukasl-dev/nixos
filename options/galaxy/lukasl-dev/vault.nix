{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy.lukasl-dev)
    domain
    addresses
    vault
    mail
    ;
in
{
  options.galaxy.lukasl-dev = {
    vault = {
      enable = lib.mkEnableOption "Enable vaultwarden server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 8222;
        readOnly = true;
        description = "Port for the vaultwarden server.";
      };
    };
  };

  config = lib.mkMerge (
    let
      rsaKey = "galaxy/lukasl-dev/vault/rsaKey";
      env = "galaxy/lukasl-dev/vault/env";
    in
    [
      {
        age.secrets = {
          ${rsaKey} = {
            rekeyFile = ../../../secrets/galaxy/lukasl-dev/vault/rsaKey.age;
            path = "/var/lib/vaultwarden/rsa_key.pem";
            mode = "0444";
          };
          ${env} = {
            rekeyFile = ../../../secrets/galaxy/lukasl-dev/vault/env.age;
            generator = {
              dependencies = {
                password = age.secrets.${mail.accounts.bot};
              };
              script =
                { decrypt, deps, ... }:
                ''
                  password="$(${decrypt} "${deps.password.file}")"

                  cat <<EOF
                  SMTP_HOST=${mail.host}
                  SMTP_PORT=465
                  SMTP_SECURITY=force_tls
                  SMTP_FROM=bot@${domain}
                  SMTP_USERNAME=bot@${domain}
                  SMTP_PASSWORD=$password
                  EOF
                '';
            };
          };
        };
      }

      (lib.mkIf vault.enable {
        galaxy.lukasl-dev = {
          proxy.rules = [
            {
              type = "https";
              name = "vault";
              to.http = "http://${addresses.local}:${toString vault.port}";
            }
          ];

          bindMounts = [
            age.secrets.${rsaKey}.path
            age.secrets.${env}.path
          ];

          modules = [
            {
              services.vaultwarden = {
                enable = true;

                package = pkgs.unstable.vaultwarden;

                config = {
                  ROCKET_ADDRESS = addresses.local;
                  ROCKET_PORT = vault.port;

                  DOMAIN = "https://vault.${domain}";
                  SIGNUPS_ALLOWED = false;
                };

                environmentFile = age.secrets.${env}.path;
              };

              networking.firewall.allowedTCPPorts = [ vault.port ];
            }
          ];
        };
      })
    ]
  );
}
