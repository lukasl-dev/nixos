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
    forge
    mail
    ;
in
{
  options.galaxy.lukasl-dev = {
    forge = {
      enable = lib.mkEnableOption "Enable forgejo server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 7297;
        readOnly = true;
        description = "Port for the forgejo http server.";
      };

      sshPort = lib.mkOption {
        type = lib.types.port;
        default = 22;
        readOnly = true;
        description = "External port for the forgejo SSH server.";
      };

      sshListenPort = lib.mkOption {
        type = lib.types.port;
        default = 2222;
        readOnly = true;
        description = "Container listen port for the forgejo SSH server.";
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "forge.${domain}";
        readOnly = true;
        description = "Public hostname for the forgejo server.";
      };

      runner = {
        enable = lib.mkEnableOption "Enable Forgejo Actions runner";

        name = lib.mkOption {
          type = lib.types.str;
          default = "lukasl-dev";
          readOnly = true;
          description = "Name of the Forgejo Actions runner.";
        };
      };
    };
  };

  config = lib.mkIf forge.enable {
    assertions = [
      {
        assertion = !(lib.elem forge.sshPort config.planet.ssh.ports);
        message = "Forgejo SSH port ${toString forge.sshPort} must not also be used by the host OpenSSH server.";
      }
    ];

    networking.firewall.allowedTCPPorts = [ forge.sshPort ];

    systemd.sockets.forgejo-ssh-proxy = {
      description = "Forgejo SSH proxy socket";
      wantedBy = [ "sockets.target" ];
      listenStreams = [ (toString forge.sshPort) ];
    };

    systemd.services.forgejo-ssh-proxy = {
      description = "Proxy Forgejo SSH to the lukasl-dev container";
      requires = [ "container@lukasl-dev.service" ];
      after = [ "container@lukasl-dev.service" ];

      serviceConfig = {
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd ${addresses.local}:${toString forge.sshListenPort}";
      };
    };

    galaxy.lukasl-dev = {
      proxy.rules = [
        {
          type = "https";
          name = "forge";
          from.host = forge.host;
          to.http = "http://${addresses.local}:${toString forge.port}";
        }
      ];

      backup.paths = [
        "/var/lib/nixos-containers/lukasl-dev/var/lib/forgejo"
      ];

      bindMounts = [
        age.secrets.${mail.accounts.bot}.path
      ];

      modules = [
        {
          services.forgejo = {
            enable = true;

            package = pkgs.unstable.forgejo;

            lfs.enable = true;

            settings = {
              DEFAULT = {
                APP_NAME = "Lukas' Forge";
              };

              server = {
                DOMAIN = forge.host;
                HTTP_ADDR = addresses.local;
                HTTP_PORT = forge.port;
                ROOT_URL = "https://${forge.host}";
                SSH_DOMAIN = forge.host;
                SSH_PORT = forge.sshPort;
                SSH_LISTEN_PORT = forge.sshListenPort;
                START_SSH_SERVER = true;
              };

              service = {
                DISABLE_REGISTRATION = true;
              };

              metrics = {
                ENABLED = true;
              };

              mailer = {
                ENABLED = true;
                SMTP_ADDR = mail.host;
                FROM = "bot@${domain}";
                USER = "bot@${domain}";
              };
            };

            secrets = {
              mailer = {
                PASSWD = age.secrets.${mail.accounts.bot}.path;
              };
            };
          };

          networking.firewall.allowedTCPPorts = [
            forge.port
            forge.sshListenPort
          ];
        }

        (
          { config, pkgs, ... }:
          let
            inherit (config.services) forgejo;
            runnerTokenFile = "${forgejo.stateDir}/runner-token.env";
          in
          lib.mkIf forge.runner.enable {
            services.gitea-actions-runner = {
              package = pkgs.forgejo-runner;

              instances.forge = {
                enable = true;
                inherit (forge.runner) name;
                url = "http://${addresses.local}:${toString forge.port}";
                tokenFile = runnerTokenFile;

                labels = [
                  "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
                  "nixos:host"
                  "native:host"
                ];

                hostPackages = with pkgs; [
                  bash
                  coreutils
                  curl
                  dnscontrol
                  gawk
                  gitFull
                  git-lfs
                  gnused
                  jq
                  nix
                  nodejs
                  bun
                  deno
                  openssh
                  rsync
                  wget
                ];
              };
            };

            systemd.services.forgejo-runner-token = {
              description = "Generate Forgejo Actions runner registration token";
              after = [ "forgejo.service" ];
              wants = [ "forgejo.service" ];
              before = [ "gitea-runner-forge.service" ];

              script = ''
                set -euo pipefail

                token="$(${lib.getExe forgejo.package} \
                  --work-path ${lib.escapeShellArg forgejo.stateDir} \
                  --config ${lib.escapeShellArg "${forgejo.customDir}/conf/app.ini"} \
                  actions generate-runner-token)"

                umask 077
                printf 'TOKEN=%s\n' "$token" > ${lib.escapeShellArg runnerTokenFile}.tmp
                mv ${lib.escapeShellArg runnerTokenFile}.tmp ${lib.escapeShellArg runnerTokenFile}
              '';

              serviceConfig = {
                Type = "oneshot";
                User = forgejo.user;
                Group = forgejo.group;
                WorkingDirectory = forgejo.stateDir;
                UMask = "0077";
              };
            };

            systemd.services.gitea-runner-forge = {
              after = [
                "forgejo.service"
                "forgejo-runner-token.service"
              ];
              wants = [ "forgejo.service" ];
              requires = [ "forgejo-runner-token.service" ];
            };
          }
        )
      ];
    };
  };
}
