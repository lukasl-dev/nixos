{
  atlas,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet) domain;
  inherit (config.planet.hosting) mail vault;
  inherit (atlas.hosting.vault) host;

  mailHost = atlas.hosting.mail.host;
  listenAddress = "127.0.0.1";
  port = 8222;
  stateDir = "/var/lib/vaultwarden";

  rsaKey = atlas.secrets.universe [
    "vault"
    "rsaKey"
  ];
  env = atlas.secrets.universe [
    "vault"
    "env"
  ];
  mailBotPassword = atlas.secrets.universe [
    "mail"
    "accounts"
    "bot"
  ];
in
{
  options.planet.hosting.vault.enable = lib.mkEnableOption "Vaultwarden server";

  config = lib.mkIf vault.enable {
    age.secrets = {
      ${mailBotPassword} = lib.mkIf (!mail.enable) {
        rekeyFile = ../../.. + "/secrets/${mailBotPassword}.age";
        intermediary = true;
      };

      ${rsaKey} = {
        rekeyFile = ../../.. + "/secrets/${rsaKey}.age";
        mode = "0400";
      };

      ${env} = {
        rekeyFile = ../../.. + "/secrets/${env}.age";
        owner = "vaultwarden";
        mode = "0400";
        generator = {
          dependencies.password = age.secrets.${mailBotPassword};
          script =
            { decrypt, deps, ... }:
            ''
              password="$(${decrypt} "${deps.password.file}")"

              cat <<EOF
              SMTP_HOST=${mailHost}
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

    services.vaultwarden = {
      enable = true;
      environmentFile = age.secrets.${env}.path;
      package = pkgs.unstable.vaultwarden;

      config = {
        ROCKET_ADDRESS = listenAddress;
        ROCKET_PORT = port;
        RSA_KEY_FILENAME = "${stateDir}/rsa_key";

        DOMAIN = "https://${host}";
        SIGNUPS_ALLOWED = false;
      };
    };

    systemd.services.vaultwarden.serviceConfig.ExecStartPre = [
      ''
        +${pkgs.writeShellScript "vaultwarden-install-rsa-key" ''
          set -euo pipefail

          source=${lib.escapeShellArg age.secrets.${rsaKey}.path}
          target=${lib.escapeShellArg "${stateDir}/rsa_key.pem"}

          if [[ -L "$target" ]]; then
            rm -f "$target"
          fi

          if ! cmp -s "$source" "$target"; then
            install -D -o vaultwarden -g vaultwarden -m 0600 \
              "$source" "$target"
          else
            chown vaultwarden:vaultwarden "$target"
            chmod 0600 "$target"
          fi
        ''}
      ''
    ];

    planet = {
      backup.dirs = [ stateDir ];

      hosting.proxy.rules.vault = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
