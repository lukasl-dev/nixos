{
  config,
  inputs,
  jail,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age;
  inherit (config.galaxy) domain matrix homunculus;
  inherit (config.planet) user;
  inherit (pkgs.stdenv.hostPlatform) system;

  stateDir = "/var/lib/hermes";

  opencodeApiKey = "universe/opencode/apiKey";
  matrixAccount = "galaxy/matrix/accounts/homunculus";
  matrixEnvironment = "galaxy/homunculus/matrixEnvironment";

  hermesLcm = pkgs.fetchFromGitHub {
    owner = "stephenschoettler";
    repo = "hermes-lcm";
    rev = "v0.19.0";
    hash = "sha256-B80HCn3BT+M1B8THMm3Ph5tpimTB68yIVkBfPaV4X40=";
  };

  pdfToMarkdown = pkgs.writeShellApplication {
    name = "pdftomd";
    runtimeInputs = [ pkgs.bun ];
    text = ''
      exec bun x markit-ai "$@"
    '';
  };

  jailedHermes = jail "hermes" inputs.hermes-agent.packages.${system}.default (
    with jail.combinators;
    [
      network
      (rw-bind stateDir stateDir)
      (add-pkg-deps [
        pkgs.curl
        pkgs.diffutils
        pkgs.exiftool
        pkgs.fd
        pkgs.file
        pkgs.findutils
        pkgs.gawk
        pkgs.gnugrep
        pkgs.gnused
        pkgs.gnutar
        pkgs.gzip
        hermesLcm
        pkgs.git
        pkgs.imagemagick
        pkgs.jpegoptim
        pkgs.jq
        pkgs.libwebp
        pkgs.oxipng
        pkgs.patch
        pdfToMarkdown
        pkgs.pngquant
        pkgs.poppler-utils
        pkgs.unzip
        pkgs.zip
      ])
    ]
  );
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
                  printf 'OPENCODE_GO_API_KEY=%s\n' "$opencode_api_key"
                '';
            };
          };
        };
      }

      {
        services.hermes-agent = {
          enable = true;
          addToSystemPackages = true;
          package = jailedHermes;

          settings = {
            model = {
              provider = "opencode-go";
              default = "deepseek-v4-flash";
            };
            plugins.enabled = [ "hermes-lcm" ];
            context.engine = "lcm";
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

          extraDependencyGroups = lib.mkMerge [
            [ "voice" ]
            (lib.mkIf matrix.enable [ "matrix" ])
          ];
          extraPlugins = [ hermesLcm ];
        };

        users.users.${user.name}.extraGroups = [ config.services.hermes-agent.group ];

        galaxy.backup.paths = [ stateDir ];
      }
    ]
  );
}
