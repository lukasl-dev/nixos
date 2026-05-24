{ config, lib, ... }:

let
  inherit (config) age;
  inherit (config.galaxy) lukasl-dev;
  inherit (config.galaxy.lukasl-dev) mail;
  inherit (config.services) go-autoconfig;

  rspamdPassword = "galaxy/lukasl-dev/mail/rspamd/password";
  rspamdWorkerController = "galaxy/lukasl-dev/mail/rspamd/workerController";

  hostname = "mail.${lukasl-dev.domain}";
  acmeDir = "/var/lib/acme/${hostname}";
in
{
  options.galaxy.lukasl-dev = {
    mail = {
      enable = lib.mkEnableOption "Enable mail server";

      host = lib.mkOption {
        type = lib.types.str;
        default = "mail.${lukasl-dev.domain}";
        readOnly = true;
      };

      accounts = {
        me = lib.mkOption {
          type = lib.types.str;
          default = "galaxy/lukasl-dev/mail/accounts/me";
          readOnly = true;
        };
        bot = lib.mkOption {
          type = lib.types.str;
          default = "galaxy/lukasl-dev/mail/accounts/bot";
          readOnly = true;
        };
        komputah = lib.mkOption {
          type = lib.types.str;
          default = "galaxy/lukasl-dev/mail/accounts/komputah";
          readOnly = true;
        };
      };
    };
  };

  config = lib.mkMerge [
    {
      age.secrets = {
        ${mail.accounts.me} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/mail/accounts/me.age;
        };
        ${mail.accounts.bot} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/mail/accounts/bot.age;
        };
        ${mail.accounts.komputah} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/mail/accounts/komputah.age;
        };

        ${rspamdPassword} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/mail/rspamd/password.age;
          intermediary = true;
        };
        ${rspamdWorkerController} = {
          rekeyFile = ../../../secrets/galaxy/lukasl-dev/mail/rspamd/workerController.age;
          generator = {
            dependencies = {
              password = age.secrets.${rspamdPassword};
            };
            script =
              { decrypt, deps, ... }:
              # bash
              ''
                password="$(${decrypt} "${deps.password.file}")"

                cat <<EOF
                password = "$password";
                EOF
              '';
          };
        };
      };
    }

    (lib.mkIf mail.enable {
      galaxy = {
        lukasl-dev.proxy.rules = [
          {
            type = "https";
            name = "maddy-autoconfig";
            from.host = go-autoconfig.settings.domain;
            to.http = "http://localhost${go-autoconfig.settings.service_addr}";
          }
          {
            type = "https";
            name = "rspamd";
            from.host = "rspamd.${lukasl-dev.domain}";
            to.http = "http://127.0.0.1:11334";
          }
        ];
        acme.domains.${lukasl-dev.domain} = {
          hosts = [ hostname ];
          reloadServices = [ "maddy.service" ];
        };
      };

      age.secrets = {
        ${mail.accounts.me}.owner = "maddy";
        ${mail.accounts.bot}.owner = "maddy";
        ${mail.accounts.komputah}.owner = "maddy";
        ${rspamdWorkerController}.owner = config.services.rspamd.user;
      };

      services = {
        maddy = {
          enable = true;

          openFirewall = true;

          primaryDomain = lukasl-dev.domain;
          localDomains = [
            lukasl-dev.domain
            "memex.md"
            "onyx.md"
          ];
          inherit hostname;

          ensureAccounts = [
            "me@${lukasl-dev.domain}"
            "bot@${lukasl-dev.domain}"
            "komputah@${lukasl-dev.domain}"
          ];
          ensureCredentials = {
            "me@${lukasl-dev.domain}".passwordFile = age.secrets.${mail.accounts.me}.path;
            "bot@${lukasl-dev.domain}".passwordFile = age.secrets.${mail.accounts.bot}.path;
            "komputah@${lukasl-dev.domain}".passwordFile = age.secrets.${mail.accounts.komputah}.path;
          };

          tls = {
            loader = "file";
            certificates = [
              {
                keyPath = "${acmeDir}/key.pem";
                certPath = "${acmeDir}/cert.pem";
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
            service_addr = ":1323";
            domain = "autoconfig.${lukasl-dev.domain}";
            imap = {
              server = hostname;
              port = 993;
              socketType = "SSL";
            };
            smtp = {
              server = hostname;
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
              domain = "project-insanity.org";
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

      environment.etc."maddy/aliases".text = ''
        info@${lukasl-dev.domain}: me@${lukasl-dev.domain}
        contact@${lukasl-dev.domain}: me@${lukasl-dev.domain}
        git@${lukasl-dev.domain}: me@${lukasl-dev.domain}
        admin@memex.md: me@lukasl.dev
        admin@onyx.md: me@lukasl.dev
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
        993
        465
        587
        25
      ];

      systemd.services.rspamd.serviceConfig.SupplementaryGroups = [ "maddy" ];
    })
  ];
}
