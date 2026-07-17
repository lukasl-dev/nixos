{
  config,
  inputs,
  lib,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy) homunculus;
  inherit (config.galaxy) domain;
  inherit (config.planet) user;

  stateDir = "/var/lib/hermes";

  opencodeApiKey = "universe/opencode/apiKey";
  matrixAccount = "galaxy/matrix/accounts/homunculus";
  matrixEnvironment = "galaxy/homunculus/matrixEnvironment";
in
{
  imports = [ inputs.hermes-agent.nixosModules.default ];

  options.galaxy.homunculus = {
    enable = lib.mkEnableOption "Hermes Agent";
  };

  config = lib.mkIf homunculus.enable (
    lib.mkMerge [
      {
        age.secrets = {
          ${matrixAccount} = {
            rekeyFile = ../../secrets/galaxy/matrix/accounts/homunculus.age;
            intermediary = true;
          };

          ${matrixEnvironment} = {
            rekeyFile = ../../secrets/galaxy/homunculus/matrixEnvironment.age;
            generator = {
              dependencies = {
                account = age.secrets.${matrixAccount};
                opencode = age.secrets.${opencodeApiKey};
              };
              script =
                { decrypt, deps, ... }:
                ''
                  password="$(${decrypt} "${deps.account.file}")"
                  opencode_api_key="$(${decrypt} "${deps.opencode.file}")"
                  printf 'MATRIX_PASSWORD=%s\n' "$password"
                  printf 'OPENAI_API_KEY=%s\n' "$opencode_api_key"
                '';
            };
          };
        };
      }

      {
        services.hermes-agent = {
          enable = true;
          addToSystemPackages = true;

          settings.model = {
            default = "deepseek-v4-flash";
            base_url = "https://opencode.ai/zen/go/v1";
          };

          environment = {
            MATRIX_HOMESERVER = "https://matrix.${domain}";
            MATRIX_USER_ID = "@homunculus:${domain}";
            MATRIX_ALLOWED_USERS = "@${user.name}:${domain}";
            MATRIX_DEVICE_ID = "HOMUNCULUS";
            MATRIX_E2EE_MODE = "required";
            MATRIX_SESSION_SCOPE = "room";
          };
          environmentFiles = [ age.secrets.${matrixEnvironment}.path ];

          extraDependencyGroups = [ "matrix" ];

          container = {
            enable = true;
            hostUsers = [ user.name ];
          };
        };

        galaxy.backup.paths = [ stateDir ];
      }
    ]
  );
}
