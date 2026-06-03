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

  isGuest = vault.mode == "guest";
  listenAddress = if isGuest then addresses.local else "127.0.0.1";
  stateDir = "/var/lib/vaultwarden";
in
{
  options.galaxy.lukasl-dev = {
    vault = {
      enable = lib.mkEnableOption "Enable vaultwarden server";

      mode = lib.mkOption {
        type = lib.types.enum [
          "guest"
          "host"
        ];
        default = config.galaxy.lukasl-dev.mode;
        description = "Whether to run vaultwarden in the lukasl-dev container or on the host.";
      };

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
              to.http = "http://${listenAddress}:${toString vault.port}";
            }
          ];

          backup.paths = [
            (if isGuest then "/var/lib/nixos-containers/lukasl-dev${stateDir}" else stateDir)
          ];

          bindMounts = lib.mkIf isGuest [
            age.secrets.${rsaKey}.path
            age.secrets.${env}.path
          ];

          modules = [
            {
              inherit (vault) mode;

              module = {
                services.vaultwarden = {
                  enable = true;

                  package = pkgs.unstable.vaultwarden;

                  config = {
                    ROCKET_ADDRESS = listenAddress;
                    ROCKET_PORT = vault.port;
                    RSA_KEY_FILENAME = "/var/lib/vaultwarden/rsa_key";

                    DOMAIN = "https://vault.${domain}";
                    SIGNUPS_ALLOWED = false;
                  };

                  environmentFile = age.secrets.${env}.path;
                };

                systemd.services.vaultwarden.serviceConfig.ExecStartPre = [
                  ''
                    +${pkgs.writeShellScript "vaultwarden-install-rsa-key" ''
                      set -euo pipefail

                      source=${lib.escapeShellArg age.secrets.${rsaKey}.path}
                      target=/var/lib/vaultwarden/rsa_key.pem

                      if [ -L "$target" ]; then
                        rm -f "$target"
                      fi

                      if ! cmp -s "$source" "$target"; then
                        install -D -o vaultwarden -g vaultwarden -m 0600 "$source" "$target"
                      else
                        chown vaultwarden:vaultwarden "$target"
                        chmod 0600 "$target"
                      fi
                    ''}
                  ''
                ];

                networking.firewall.allowedTCPPorts = lib.mkIf isGuest [ vault.port ];
              };
            }
          ];
        };
      })
    ]
  );
}
