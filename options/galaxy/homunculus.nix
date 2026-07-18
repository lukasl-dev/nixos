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
  inherit (config.planet.programs) plann;
  inherit (pkgs.stdenv.hostPlatform) system;

  stateDir = "/var/lib/hermes";

  opencodeApiKey = "universe/opencode/apiKey";
  discordToken = "galaxy/homunculus/discord/token";
  environment = "galaxy/homunculus/env";
  hassToken = "galaxy/hass/token";
  matrixAccount = "galaxy/matrix/accounts/homunculus";

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

  plannSkills = pkgs.runCommand "hermes-plann-skills" { } ''
    mkdir -p "$out/plann"
    cp ${../planet/programs/pi/skills/plann/SKILL.md} "$out/plann/SKILL.md"
  '';

  jailedHermes = jail "hermes" inputs.hermes-agent.packages.${system}.default (
    with jail.combinators;
    [
      network
      (rw-bind stateDir stateDir)
      (ro-bind plann.configFile plann.configFile)
      (ro-bind plannSkills plannSkills)
      (add-pkg-deps [
        pkgs.agent-browser
        pkgs.chromium
        pkgs.curl
        pkgs.diffutils
        pkgs.exiftool
        pkgs.fd
        pkgs.ffmpeg-headless
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
        plann.package
        pkgs.pngquant
        pkgs.poppler-utils
        pkgs.unzip
        pkgs.yt-dlp
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
          ${discordToken} = {
            rekeyFile = ../../secrets/galaxy/homunculus/discord/token.age;
            intermediary = true;
          };

          ${hassToken} = {
            rekeyFile = ../../secrets/galaxy/hass/token.age;
            intermediary = true;
          };

          ${matrixAccount} = {
            rekeyFile = ../../secrets/galaxy/matrix/accounts/homunculus.age;
            intermediary = true;
          };

          ${environment} = {
            rekeyFile = ../../secrets/galaxy/homunculus/env.age;
            generator = {
              dependencies = {
                account = age.secrets.${matrixAccount};
                discord = age.secrets.${discordToken};
                hass = age.secrets.${hassToken};
                opencode = age.secrets.${opencodeApiKey};
              };
              script =
                { decrypt, deps, ... }:
                ''
                  password="$(${decrypt} "${deps.account.file}")"
                  discord_token="$(${decrypt} "${deps.discord.file}")"
                  hass_token="$(${decrypt} "${deps.hass.file}")"
                  opencode_api_key="$(${decrypt} "${deps.opencode.file}")"
                  printf 'MATRIX_PASSWORD=%s\n' "$password"
                  printf 'DISCORD_BOT_TOKEN=%s\n' "$discord_token"
                  printf 'HASS_TOKEN=%s\n' "$hass_token"
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
            toolsets = [
              "hermes-cli"
              "browser"
            ];
            browser.engine = "chrome";
            model = {
              provider = "opencode-go";
              default = "deepseek-v4-flash";
              persist_switch_by_default = false;
            };
            model_aliases = {
              flash = {
                provider = "opencode-go";
                model = "deepseek-v4-flash";
              };
              luna = {
                provider = "openai-codex";
                model = "gpt-5.6-luna";
              };
              terra = {
                provider = "openai-codex";
                model = "gpt-5.6-terra";
              };
              sol = {
                provider = "openai-codex";
                model = "gpt-5.6-sol";
              };
            };
            delegation = {
              provider = "openai-codex";
              model = "gpt-5.6-sol";
            };
            plugins.enabled = [ "hermes-lcm" ];
            context.engine = "lcm";
            skills.external_dirs = [ plannSkills ];
          };

          environment = {
            AGENT_BROWSER_ARGS = "--no-sandbox,--disable-dev-shm-usage";
            AGENT_BROWSER_EXECUTABLE_PATH = lib.getExe pkgs.chromium;
            DISCORD_ALLOWED_USERS = "370883999528124416";
            HASS_URL = "https://home.${domain}";
            MATRIX_HOMESERVER = "https://matrix.${domain}";
            MATRIX_USER_ID = "@homunculus:${domain}";
            MATRIX_ALLOWED_USERS = "@${user.name}:${domain}";
            MATRIX_DEVICE_ID = "HOMUNCULUS";
            MATRIX_E2EE_MODE = "required";
            MATRIX_SESSION_SCOPE = "room";
          };
          environmentFiles = [ age.secrets.${environment}.path ];

          extraDependencyGroups = [
            "homeassistant"
            "messaging"
            "voice"
            "matrix"
          ];
          extraPlugins = [ hermesLcm ];
        };

        users.users = {
          ${user.name}.extraGroups = [ config.services.hermes-agent.group ];
          ${config.services.hermes-agent.user}.extraGroups = [ "plann" ];
        };

        galaxy.backup.paths = [ stateDir ];
      }
    ]
  );
}
