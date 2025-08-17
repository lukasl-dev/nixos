{ config, ... }:

let
  domain = config.universe.domain;
  mailHost = "mail.${domain}";

  acmeDir = config.security.acme.certs.${domain}.directory;
in
{
  services.postfix = {
    enable = true;

    hostname = mailHost;
    domain = domain;
    origin = domain;

    enableSmtp = true;
    enableSubmission = true;
    enableSubmissions = true;

    destination = [
      domain
      mailHost
      "localhost"
    ];
    localRecipients = [
      "root"
      "postmaster"
    ];

    rootAlias = "contact@${domain}";
    postmasterAlias = "contact@${domain}";

    networks = [
      "127.0.0.0/8"
      "[::1]/128"
    ];
    recipientDelimiter = "+";

    extraConfig = ''
      myhostname = ${mailHost}
      mydomain   = ${domain}
      myorigin   = ${domain}
      inet_interfaces = all

      smtpd_tls_cert_file = ${acmeDir}/fullchain.pem
      smtpd_tls_key_file  = ${acmeDir}/key.pem
      smtpd_tls_security_level = may
      smtp_tls_security_level  = may
      smtpd_tls_auth_only = yes

      smtpd_recipient_restrictions =
        permit_mynetworks,
        permit_sasl_authenticated,
        reject_unauth_destination
    '';

    # Per-port overrides
    submissionOptions = {
      # 587: force STARTTLS, enable SASL (once you add a SASL backend)
      smtpd_tls_security_level = "encrypt";
      smtpd_sasl_auth_enable = "yes";
      # if/when you enable Dovecot SASL, also set:
      # smtpd_sasl_type = "dovecot";
      # smtpd_sasl_path = "private/auth";
    };

    submissionsOptions = {
      # 465: implicit TLS, enable SASL (once you add a SASL backend)
      smtpd_sasl_auth_enable = "yes";
      # if/when you enable Dovecot SASL, also set:
      # smtpd_sasl_type = "dovecot";
      # smtpd_sasl_path = "private/auth";
    };

    setSendmail = true;
  };

  networking.firewall.allowedTCPPorts = [
    25
    587
    465
  ];
}
