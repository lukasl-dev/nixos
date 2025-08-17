{ config, ... }:

let
  domain = config.universe.domain;

  acmeDir = config.security.acme.certs.${domain}.directory;
in
{
  services.dovecot2 = {
    enable = true;
    enableImap = true;
    enablePop3 = true;

    # TLS certs (same ones Postfix uses for mail.${domain})
    sslServerCert = "${acmeDir}/fullchain.pem";
    sslServerKey = "${acmeDir}/key.pem";

    extraConfig = ''
      protocols = imap lmtp pop3
      mail_location = maildir:~/Maildir

      disable_plaintext_auth = yes
      auth_mechanisms = plain login

      auth_username_format = %n

      passdb {
        driver = passwd-file
        args = scheme=SHA512-CRYPT /etc/dovecot/users
      }

      userdb {
        driver = passwd
      }

      service auth {
        unix_listener /var/spool/postfix/private/auth {
          mode = 0660
          user = postfix
          group = postfix
        }
      }

      service lmtp {
        unix_listener /var/spool/postfix/private/dovecot-lmtp {
          mode = 0600
          user = postfix
          group = postfix
        }
      }

      ssl_min_protocol = TLSv1.2
    '';
  };

  # TODO: this causes errors that the user is not properly configured, implying
  # that dovecot does not setup this user?
  # users.users.dovecot = {
  #   isSystemUser = true;
  #   extraGroups = [ "acme" ];
  # };

  networking.firewall.allowedTCPPorts = [
    143
    993
    110
    995
  ];

  sops = {
    secrets."planets/pollux/dovecot/users/lukas" = { };

    templates."dovecot/users" = {
      path = "/etc/dovecot/users";
      group = "dovecot";
      content = ''
        lukas:{SHA512-CRYPT}${config.sops.placeholder."planets/pollux/dovecot/users/lukas"}
      '';
    };
  };
}
