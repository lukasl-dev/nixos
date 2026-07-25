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
  inherit (config.planet.hosting) forge mail;
  inherit (atlas.hosting.forge) host;

  listenAddress = "127.0.0.1";
  port = 7297;
  sshPort = config.planet.services.ssh.port;

  stateDir = "/var/lib/forgejo";
  customDir = "${stateDir}/custom";
  runnerTokenFile = "${stateDir}/runner-token.env";
  runnerName = "lukasl-dev";

  forgejoPackage = pkgs.forgejo;
  mailBotPassword = atlas.secrets.universe [
    "mail"
    "accounts"
    "bot"
  ];
in
{
  options.planet.hosting.forge.enable = lib.mkEnableOption "Forgejo server";

  config = lib.mkIf forge.enable {
    age.secrets.${mailBotPassword} = lib.mkIf (!mail.enable) {
      rekeyFile = ../../.. + "/secrets/${mailBotPassword}.age";
      mode = "0400";
    };

    services = {
      forgejo = {
        enable = true;
        package = forgejoPackage;
        lfs.enable = true;

        settings = {
          DEFAULT.APP_NAME = "Lukas' Forge";

          server = {
            DOMAIN = host;
            HTTP_ADDR = listenAddress;
            HTTP_PORT = port;
            ROOT_URL = "https://${host}";

            SSH_DOMAIN = host;
            SSH_PORT = sshPort;
            START_SSH_SERVER = false;
          };

          service.DISABLE_REGISTRATION = true;
          metrics.ENABLED = true;

          mailer = {
            ENABLED = true;
            PROTOCOL = "smtps";
            SMTP_ADDR = atlas.hosting.mail.host;
            SMTP_PORT = 465;
            FROM = "bot@${domain}";
            USER = "bot@${domain}";
          };
        };

        secrets.mailer.PASSWD = age.secrets.${mailBotPassword}.path;
      };

      gitea-actions-runner = {
        package = pkgs.forgejo-runner;

        instances.forge = {
          enable = true;
          name = runnerName;
          url = "http://${listenAddress}:${toString port}";
          tokenFile = runnerTokenFile;

          labels = [
            "ubuntu-latest:docker://ghcr.io/catthehacker/ubuntu:act-latest"
            "nixos:host"
            "native:host"
          ];

          hostPackages = with pkgs; [
            bash
            bun
            coreutils
            curl
            deno
            dnscontrol
            gawk
            gitFull
            git-lfs
            gnused
            jq
            nix
            nodejs
            openssh
            rsync
            wget
          ];
        };
      };
    };

    systemd.services = {
      forgejo-runner-token = {
        description = "Generate Forgejo Actions runner registration token";
        after = [ "forgejo.service" ];
        requires = [ "forgejo.service" ];
        before = [ "gitea-runner-forge.service" ];

        script = ''
          set -euo pipefail

          attempt=1
          while true; do
            if token="$(${lib.getExe forgejoPackage} \
              --work-path ${lib.escapeShellArg stateDir} \
              --config ${lib.escapeShellArg "${customDir}/conf/app.ini"} \
              actions generate-runner-token)" && [[ -n "$token" ]]; then
              break
            fi

            if [[ "$attempt" -ge 60 ]]; then
              echo "Forgejo did not become ready for runner token generation" \
                >&2
              exit 1
            fi

            attempt=$((attempt + 1))
            sleep 1
          done

          umask 077
          printf 'TOKEN=%s\n' "$token" \
            >${lib.escapeShellArg "${runnerTokenFile}.tmp"}
          mv ${lib.escapeShellArg "${runnerTokenFile}.tmp"} \
            ${lib.escapeShellArg runnerTokenFile}
        '';

        serviceConfig = {
          Type = "oneshot";
          User = "forgejo";
          Group = "forgejo";
          WorkingDirectory = stateDir;
          UMask = "0077";
        };
      };

      gitea-runner-forge = {
        after = [
          "forgejo.service"
          "forgejo-runner-token.service"
        ];
        requires = [
          "forgejo.service"
          "forgejo-runner-token.service"
        ];
      };
    };

    planet = {
      backup.dirs = [ stateDir ];

      hosting.proxy.rules.forge = {
        ingress.host = host;
        upstream.http.url = "http://${listenAddress}:${toString port}";
      };
    };
  };
}
