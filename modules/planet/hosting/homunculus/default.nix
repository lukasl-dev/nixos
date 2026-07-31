{
  atlas,
  config,
  inputs,
  jail,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) age;
  inherit (config.planet) domain;
  inherit (config.planet.hosting) homunculus;

  steward = atlas.travellers.eval config.planet.steward.traveller;
  stewardName = steward.user.name;

  stateDir = "/var/lib/hermes";
  soulFile = ./SOUL.md;
  hermesAgent = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;

  opencodeApiKey = atlas.secrets.universe [
    "opencode"
    "apiKey"
  ];
  discordToken = atlas.secrets.universe [
    "homunculus"
    "discord"
    "token"
  ];
  environment = atlas.secrets.universe [
    "homunculus"
    "env"
  ];
  hassToken = atlas.secrets.universe [
    "hass"
    "token"
  ];
  matrixAccount = atlas.secrets.universe [
    "matrix"
    "accounts"
    "homunculus"
  ];

  hermesLcm = pkgs.fetchFromGitHub {
    name = "hermes-lcm";
    owner = "stephenschoettler";
    repo = "hermes-lcm";
    rev = "v0.19.0";
    hash = "sha256-B80HCn3BT+M1B8THMm3Ph5tpimTB68yIVkBfPaV4X40=";
  };
in
{
  imports = [ inputs.hermes-agent.nixosModules.default ];

  options.planet.hosting.homunculus.enable = lib.mkEnableOption "Hermes Agent";

  config = lib.mkIf homunculus.enable {
    age.secrets = {
      ${discordToken} = {
        rekeyFile = ../../../.. + "/secrets/${discordToken}.age";
        intermediary = true;
      };

      ${hassToken} = {
        rekeyFile = ../../../.. + "/secrets/${hassToken}.age";
        intermediary = true;
      };

      ${matrixAccount} = {
        rekeyFile = ../../../.. + "/secrets/${matrixAccount}.age";
        intermediary = true;
      };

      ${environment} = {
        rekeyFile = ../../../.. + "/secrets/${environment}.age";
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

    services.hermes-agent = {
      enable = true;
      addToSystemPackages = true;
      package = jail "hermes" hermesAgent (
        with jail.combinators;
        [
          network
          (rw-bind stateDir stateDir)
          (add-pkg-deps [
            pkgs.agent-browser
            pkgs.bzip2
            pkgs.chromium
            pkgs.curl
            pkgs.ddgr
            pkgs.diffutils
            pkgs.duckdb
            pkgs.exiftool
            pkgs.fd
            pkgs.ffmpeg-headless
            pkgs.file
            pkgs.findutils
            pkgs.gawk
            pkgs.git
            pkgs.gnugrep
            pkgs.gnused
            pkgs.gnutar
            pkgs.graphviz
            pkgs.gzip
            hermesLcm
            pkgs.imagemagick
            pkgs.jpegoptim
            pkgs.jq
            pkgs.libwebp
            pkgs.nix
            pkgs.nix-prefetch-github
            pkgs.oxipng
            pkgs.p7zip
            pkgs.pandoc
            pkgs.patch
            pkgs.pngquant
            pkgs.poppler-utils
            pkgs.ripgrep
            pkgs.sqlite
            pkgs.tesseract
            pkgs.texlive.combined.scheme-medium
            pkgs.unzip
            pkgs.xz
            pkgs.yq-go
            pkgs.yt-dlp
            pkgs.zip
            pkgs.zstd
            pkgs.csound
            pkgs.fluidsynth
            pkgs.soundfont-fluid
            pkgs.sox
            (pkgs.writeShellApplication {
              name = "pdftomd";
              runtimeInputs = [ pkgs.bun ];
              text = ''
                exec bun x markit-ai "$@"
              '';
            })
            (pkgs.python3.withPackages (
              pythonPackages: with pythonPackages; [
                beautifulsoup4
                lxml
                matplotlib
                mido
                numpy
                openpyxl
                pandas
                scikit-learn
                scipy
                seaborn
                statsmodels
                sympy
              ]
            ))
          ])
        ]
      );

      settings = {
        toolsets = [
          "hermes-cli"
          "browser"
        ];
        browser.engine = "chrome";
        model = {
          provider = "opencode-go";
          default = "hy3";
          persist_switch_by_default = false;
        };
        auxiliary = {
          title_generation = {
            enabled = true;
            provider = "opencode-go";
            model = "deepseek-v4-flash";
            timeout = 30;
          };
          compression = {
            provider = "opencode-go";
            model = "deepseek-v4-flash";
            timeout = 120;
          };
          web_extract = {
            provider = "opencode-go";
            model = "deepseek-v4-flash";
            timeout = 360;
          };
          approval = {
            provider = "opencode-go";
            model = "deepseek-v4-flash";
            timeout = 30;
          };
          skills_hub = {
            provider = "opencode-go";
            model = "deepseek-v4-flash";
            timeout = 30;
          };
          mcp = {
            provider = "opencode-go";
            model = "deepseek-v4-flash";
            timeout = 30;
          };
          triage_specifier = {
            provider = "opencode-go";
            model = "deepseek-v4-flash";
            timeout = 120;
          };
          kanban_decomposer = {
            provider = "opencode-go";
            model = "deepseek-v4-flash";
            timeout = 120;
          };
          profile_describer = {
            provider = "opencode-go";
            model = "deepseek-v4-flash";
            timeout = 30;
          };
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
          qwen = {
            provider = "opencode-go";
            model = "qwen3.7-plus";
          };
        };
        delegation = {
          provider = "openai-codex";
          model = "gpt-5.6-sol";
        };
        plugins.enabled = [ "hermes-lcm" ];
        context.engine = "lcm";
      };

      environment = {
        AGENT_BROWSER_ARGS = "--no-sandbox,--disable-dev-shm-usage";
        AGENT_BROWSER_EXECUTABLE_PATH = lib.getExe pkgs.chromium;
        DISCORD_ALLOWED_USERS = "370883999528124416";
        HASS_URL = "https://${atlas.hosting.home.host}";
        MATRIX_HOMESERVER = "https://${atlas.hosting.matrix.host}";
        MATRIX_USER_ID = "@homunculus:${domain}";
        MATRIX_ALLOWED_USERS = "@${stewardName}:${domain}";
        MATRIX_DEVICE_ID = "HOMUNCULUS";
        MATRIX_E2EE_MODE = "required";
        MATRIX_SESSION_SCOPE = "room";
        MATRIX_DM_AUTO_THREAD = "true";
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

    users = {
      users = {
        ${stewardName}.extraGroups = [ config.services.hermes-agent.group ];
      };
    };

    systemd.services.hermes-agent.restartTriggers = [
      age.secrets.${environment}.rekeyFile
      soulFile
    ];

    system.activationScripts.hermes-agent-soul = lib.stringAfter [ "hermes-agent-setup" ] ''
      install \
        -o ${config.services.hermes-agent.user} \
        -g ${config.services.hermes-agent.group} \
        -m 0640 \
        ${soulFile} \
        ${stateDir}/.hermes/SOUL.md
    '';

    planet.backup.dirs = [ stateDir ];
  };
}
