{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy) domain forge mail;

  listenAddress = "127.0.0.1";
  stateDir = "/var/lib/forgejo";

  forgeModule = {
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
          HTTP_ADDR = listenAddress;
          HTTP_PORT = forge.port;
          ROOT_URL = "https://${forge.host}";
          SSH_DOMAIN = forge.host;
          SSH_PORT = forge.sshPort;
          SSH_LISTEN_PORT = forge.sshPort;
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

      secrets.mailer.PASSWD = age.secrets.${mail.accounts.bot}.path;
    };

    # Forgejo's built-in SSH server needs a capability in the host user
    # namespace to bind the privileged port. The module's PrivateUsers
    # sandbox would confine that capability to a separate user namespace.
    systemd.services.forgejo.serviceConfig = {
      PrivateUsers = lib.mkForce false;
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
      CapabilityBoundingSet = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
    };
  };

  forgejoStateDir = "/var/lib/forgejo";
  forgejoCustomDir = "${forgejoStateDir}/custom";
  runnerTokenFile = "${forgejoStateDir}/runner-token.env";

  runnerModule = lib.mkIf forge.runner.enable {
    virtualisation.docker.enable = true;

    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;

      instances.forge = {
        enable = true;
        inherit (forge.runner) name;
        url = "http://${listenAddress}:${toString forge.port}";
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
      requires = [ "forgejo.service" ];
      before = [ "gitea-runner-forge.service" ];

      script = ''
        set -euo pipefail

        attempt=1
        while true; do
          if token="$(${lib.getExe pkgs.unstable.forgejo} \
            --work-path ${lib.escapeShellArg forgejoStateDir} \
            --config ${lib.escapeShellArg "${forgejoCustomDir}/conf/app.ini"} \
            actions generate-runner-token)" && [ -n "$token" ]; then
            break
          fi

          if [ "$attempt" -ge 60 ]; then
            echo "Forgejo did not become ready for runner token generation" >&2
            exit 1
          fi

          attempt=$((attempt + 1))
          sleep 1
        done

        umask 077
        printf 'TOKEN=%s\n' "$token" > ${lib.escapeShellArg runnerTokenFile}.tmp
        mv ${lib.escapeShellArg runnerTokenFile}.tmp ${lib.escapeShellArg runnerTokenFile}
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "forgejo";
        Group = "forgejo";
        WorkingDirectory = forgejoStateDir;
        UMask = "0077";
      };
    };

    systemd.services.gitea-runner-forge = {
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
in
{
  options.galaxy = {
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

  config = lib.mkIf forge.enable (
    lib.mkMerge [
      forgeModule
      runnerModule
      {
        assertions = [
          {
            assertion = !(lib.elem forge.sshPort config.planet.ssh.ports);
            message = "Forgejo SSH port ${toString forge.sshPort} must not also be used by the host OpenSSH server.";
          }
        ];

        networking.firewall.allowedTCPPorts = [ forge.sshPort ];

        galaxy = {
          proxy.rules = [
            {
              name = "forge";
              from.host = forge.host;
              to.http = "http://${listenAddress}:${toString forge.port}";
            }
          ];
          backup.paths = [ stateDir ];
        };
      }
    ]
  );
}
