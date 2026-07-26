{
  atlas,
  config,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet) domain;
  inherit (config.planet.hosting) mail;
  inherit (atlas.hosting) autoconfig rspamd;
  inherit (atlas.hosting.mail) host;

  autoconfigPort = 1323;
  rspamdPort = 11334;
  stateDir = "/var/lib/maddy";

  account =
    name:
    atlas.secrets.universe [
      "mail"
      "accounts"
      name
    ];

  mePassword = account "me";
  botPassword = account "bot";
  komputahPassword = account "komputah";

  rspamdPassword = atlas.secrets.universe [
    "mail"
    "rspamd"
    "password"
  ];
  rspamdWorkerController = atlas.secrets.universe [
    "mail"
    "rspamd"
    "workerController"
  ];

  acmeDir = "/var/lib/acme/${host}";
  acmeService = "acme-${host}.service";
in
{
  options.planet.hosting.mail.enable = lib.mkEnableOption "mail server";

  config = lib.mkIf mail.enable {
    age.secrets = {
      ${mePassword} = {
        rekeyFile = ../../.. + "/secrets/${mePassword}.age";
        owner = "maddy";
        mode = "0400";
      };

      ${botPassword} = {
        rekeyFile = ../../.. + "/secrets/${botPassword}.age";
        owner = "maddy";
        mode = "0400";
      };

      ${komputahPassword} = {
        rekeyFile = ../../.. + "/secrets/${komputahPassword}.age";
        owner = "maddy";
        mode = "0400";
      };

      ${rspamdPassword} = {
        rekeyFile = ../../.. + "/secrets/${rspamdPassword}.age";
        intermediary = true;
      };

      ${rspamdWorkerController} = {
        rekeyFile = ../../.. + "/secrets/${rspamdWorkerController}.age";
        owner = config.services.rspamd.user;
        mode = "0400";
        generator = {
          dependencies.password = age.secrets.${rspamdPassword};
          script =
            { decrypt, deps, ... }:
            ''
              password="$(${decrypt} "${deps.password.file}")"
              printf 'password = "%s";\n' "$password"
            '';
        };
      };
    };

    services = {
      maddy = {
        enable = true;
        openFirewall = true;

        primaryDomain = domain;
        localDomains = [
          domain
          "memex.md"
          "onyx.md"
        ];
        hostname = host;

        ensureAccounts = [
          "me@${domain}"
          "bot@${domain}"
          "komputah@${domain}"
        ];
        ensureCredentials = {
          "me@${domain}".passwordFile = age.secrets.${mePassword}.path;
          "bot@${domain}".passwordFile = age.secrets.${botPassword}.path;
          "komputah@${domain}".passwordFile = age.secrets.${komputahPassword}.path;
        };

        tls = {
          loader = "file";
          certificates = [
            {
              keyPath = "${acmeDir}/key.pem";
              certPath = "${acmeDir}/fullchain.pem";
            }
          ];
        };

        config = ''
          auth.pass_table local_authdb {
            table sql_table {
              driver sqlite3
              dsn credentials.db
              table_name passwords
            }
          }

          storage.imapsql local_mailboxes {
            driver sqlite3
            dsn imapsql.db
          }

          table.chain local_rewrites {
            optional_step regexp "(.+)\\+(.+)@(.+)" "$1@$3"
            optional_step static {
              entry postmaster postmaster@$(primary_domain)
            }
            optional_step file /etc/maddy/aliases
          }

          table.chain rcpt_rewrites {
            optional_step regexp "(.+)\\+(.+)@(.+)" "$1@$3"
            optional_step static {
              entry postmaster postmaster@$(primary_domain)
            }
            optional_step file /etc/maddy/aliases
            optional_step regexp "(.+)@$(primary_domain)" "me@$(primary_domain)"
          }

          msgpipeline local_routing {
            check {
              rspamd {
                api_path http://127.0.0.1:11333
              }
            }

            destination "bot@$(primary_domain)" {
              reject 550 5.1.1 "bot does not accept mail"
            }

            destination "komputah@$(primary_domain)" {
              deliver_to &local_mailboxes
            }

            destination postmaster $(local_domains) {
              modify { replace_rcpt &rcpt_rewrites }
              deliver_to &local_mailboxes
            }

            default_destination {
              reject 550 5.1.1 "User doesn't exist"
            }
          }

          smtp tcp://0.0.0.0:25 {
            limits {
              all rate 20 1s
              all concurrency 10
            }
            dmarc yes
            check {
              require_mx_record
              dkim
              spf
            }
            source $(local_domains) {
              reject 501 5.1.8 "Use Submission for outgoing SMTP"
            }
            default_source {
              destination postmaster $(local_domains) {
                deliver_to &local_routing
              }
              default_destination {
                reject 550 5.1.1 "User doesn't exist"
              }
            }
          }

          submission tls://0.0.0.0:465 tcp://0.0.0.0:587 {
            limits { all rate 50 1s }
            auth &local_authdb

            source $(local_domains) {
              check {
                authorize_sender {
                  prepare_email &local_rewrites

                  user_to_email static {
                    entry "me@$(primary_domain)" "$(primary_domain)"
                    entry "bot@$(primary_domain)" "bot@$(primary_domain)"
                    entry "komputah@$(primary_domain)" "komputah@$(primary_domain)"
                  }
                }
              }

              destination postmaster $(local_domains) {
                deliver_to &local_routing
              }

              default_destination {
                modify { dkim $(primary_domain) "default" }
                deliver_to &remote_queue
              }
            }

            default_source {
              reject 501 5.1.8 "Non-local sender domain"
            }
          }

          target.remote outbound_delivery {
            limits {
              destination rate 20 1s
              destination concurrency 10
            }
            mx_auth {
              dane
              mtasts {
                cache fs
                fs_dir mtasts_cache/
              }
              local_policy {
                min_tls_level encrypted
                min_mx_level none
              }
            }
          }

          target.queue remote_queue {
            target &outbound_delivery
            autogenerated_msg_domain $(primary_domain)
            bounce {
              destination postmaster $(local_domains) {
                deliver_to &local_routing
              }
              default_destination {
                reject 550 5.0.0 "Refusing to send DSNs to non-local addresses"
              }
            }
          }

          imap tls://0.0.0.0:993 tcp://0.0.0.0:143 {
            auth &local_authdb
            storage &local_mailboxes
          }
        '';
      };

      go-autoconfig = {
        enable = true;
        settings = {
          service_addr = ":${toString autoconfigPort}";
          domain = autoconfig.host;
          imap = {
            server = host;
            port = 993;
            socketType = "SSL";
          };
          smtp = {
            server = host;
            port = 587;
            socketType = "STARTTLS";
          };
        };
      };

      rspamd = {
        enable = true;
        locals = {
          "dkim_signing.conf".text = ''
            selector = "default";
            domain = "${domain}";
            path = "/var/lib/maddy/dkim_keys/$domain_$selector.key";
          '';

          "redis.conf".text = ''
            servers = "${config.services.redis.servers.rspamd.unixSocket}";
          '';

          "classifier-bayes.conf".text = ''
            backend = "redis";
            autolearn = true;
          '';

          "options.inc".text = ''
            dns {
              nameserver = ["1.1.1.1:53", "8.8.8.8:53"];
            }
          '';
        };
        workers.controller.includes = [
          age.secrets.${rspamdWorkerController}.path
        ];
      };

      redis.servers.rspamd = {
        enable = true;
        port = 0;
        inherit (config.services.rspamd) user;
      };
    };

    security.acme.certs.${host}.reloadServices = [ "maddy.service" ];

    environment.etc."maddy/aliases".text = ''
      info@${domain}: me@${domain}
      contact@${domain}: me@${domain}
      git@${domain}: me@${domain}
    '';

    users = {
      users.maddy = {
        isSystemUser = true;
        group = "maddy";
        extraGroups = [ "acme" ];
      };
      groups.maddy = { };
    };

    networking.firewall.allowedTCPPorts = [
      25
      143
      465
      587
      993
    ];

    systemd.services = {
      maddy = {
        wants = [ acmeService ];
        after = [ acmeService ];
      };
      rspamd.serviceConfig.SupplementaryGroups = [ "maddy" ];
    };

    planet = {
      backup.dirs = [ stateDir ];

      hosting.proxy.rules = {
        maddy-autoconfig = {
          ingress.host = autoconfig.host;
          upstream.http.url = "http://127.0.0.1:${toString autoconfigPort}";
        };
        rspamd = {
          ingress.host = rspamd.host;
          upstream.http.url = "http://127.0.0.1:${toString rspamdPort}";
        };
      };
    };
  };
}
