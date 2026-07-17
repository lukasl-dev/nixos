{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy) domain matrix;
  inherit (config.planet) user;
  inherit (config.services) mautrix-whatsapp;

  listenAddress = "127.0.0.1";

  stateDir = "/var/lib/mautrix-whatsapp";
  appserviceDir = "${stateDir}/appservices";
  registrationFile = "${stateDir}/whatsapp-registration.yaml";

  pickleKey = "galaxy/matrix/whatsapp/pickleKey";
  environment = "galaxy/matrix/whatsapp/environment";

  registrationConfig =
    (pkgs.formats.json { }).generate "mautrix-whatsapp-registration-config.json"
      mautrix-whatsapp.settings;
in
{
  config = lib.mkIf matrix.enable {
    age.secrets = {
      ${pickleKey} = {
        rekeyFile = ../../../secrets/galaxy/matrix/whatsapp/pickleKey.age;
        generator.script = "base64";
        intermediary = true;
      };

      ${environment} = {
        rekeyFile = ../../../secrets/galaxy/matrix/whatsapp/environment.age;
        owner = "mautrix-whatsapp";
        group = "mautrix-whatsapp";
        mode = "0400";
        generator = {
          dependencies.pickleKey = age.secrets.${pickleKey};
          script =
            { decrypt, deps, ... }:
            ''
              pickleKey="$(${decrypt} ${lib.escapeShellArg deps.pickleKey.file})"
              printf 'MAUTRIX_WHATSAPP_ENCRYPTION_PICKLE_KEY=%s\n' "$pickleKey"
            '';
        };
      };
    };

    services = {
      matrix-tuwunel.settings.global.appservice_dir = appserviceDir;

      mautrix-whatsapp = {
        enable = true;
        package = pkgs.mautrix-whatsapp.override { withGoolm = true; };
        registerToSynapse = false;
        serviceDependencies = [ "tuwunel.service" ];
        environmentFile = age.secrets.${environment}.path;

        settings = {
          homeserver = {
            address = "http://${listenAddress}:${toString matrix.port}";
            inherit domain;
          };

          appservice.hostname = listenAddress;

          bridge = {
            relay.enabled = false;
            permissions = {
              ${domain} = "user";
              "@${user.name}:${domain}" = "admin";
            };
          };

          encryption = {
            allow = true;
            default = true;
            require = true;
            pickle_key = "$MAUTRIX_WHATSAPP_ENCRYPTION_PICKLE_KEY";
          };
        };
      };
    };

    systemd.services = {
      mautrix-whatsapp-registration = {
        description = "Generate the mautrix-whatsapp appservice registration";
        before = [
          "mautrix-whatsapp.service"
          "tuwunel.service"
        ];

        serviceConfig = {
          Type = "oneshot";
          User = "mautrix-whatsapp";
          Group = "mautrix-whatsapp";
          StateDirectory = baseNameOf stateDir;
          StateDirectoryMode = "0750";
          WorkingDirectory = stateDir;
          UMask = "0027";
        };

        script = # bash
          ''
            if [[ ! -s '${registrationFile}' ]]; then
              ${lib.getExe mautrix-whatsapp.package} \
                --generate-registration \
                --config='${registrationConfig}' \
                --registration='${registrationFile}'
            fi

            chmod 0640 '${registrationFile}'
            mkdir -p '${appserviceDir}'
            chmod 0750 '${appserviceDir}'
            ln -sfn '${registrationFile}' '${appserviceDir}/whatsapp-registration.yaml'
          '';
      };

      mautrix-whatsapp = {
        requires = [ "mautrix-whatsapp-registration.service" ];
        after = [ "mautrix-whatsapp-registration.service" ];
      };

      tuwunel = {
        requires = [ "mautrix-whatsapp-registration.service" ];
        after = [ "mautrix-whatsapp-registration.service" ];
        serviceConfig.SupplementaryGroups = [ "mautrix-whatsapp" ];
      };
    };

    galaxy.backup.paths = [ stateDir ];
  };
}
