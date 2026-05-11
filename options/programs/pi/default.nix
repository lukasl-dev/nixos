{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.planet) user;
  inherit (config.planet.programs) pi;

  inherit (pkgs.stdenv.hostPlatform) system;

  allowedPiSecretPaths = map toString [
    pi.secrets.opencode
    pi.secrets.exa
  ];

  deniedAgeSecretPaths = lib.filter (path: !(builtins.elem path allowedPiSecretPaths)) (
    lib.mapAttrsToList (_: secret: toString secret.path) config.age.secrets
  );

  deniedAgeSecretRules = lib.concatMapStringsSep "\n" (
    path: ''audit deny "${path}" rwklm, ''
  ) deniedAgeSecretPaths;

  pi-fff = pkgs.buildNpmPackage {
    pname = "pi-fff";
    version = "0.6.4";
    src = inputs.fff-nvim.outPath;
    npmDepsHash = "sha256-BbGGN7Y7x9Yf5xXMjoGqJFLj7Hw1p19DcJRiG5lkkRw=";
    npmInstallFlags = [ "--include=optional" ];
    npmRebuildFlags = [ "--ignore-scripts" ];
    dontNpmBuild = true;

    buildPhase = ''
      runHook preBuild

      npm run build --workspace packages/fff-node

      mkdir -p packages/fff-node/bin
      cp ${inputs.fff-nvim.packages.${system}.default}/lib/libfff_c.so packages/fff-node/bin/

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p \
        $out/packages \
        $out/target/release \
        $out/node_modules \
        $out/node_modules/@ff-labs \
        $out/node_modules/@yuuang

      cp -r packages/pi-fff $out/packages/
      cp -r packages/fff-node $out/packages/
      cp -r node_modules/ffi-rs $out/node_modules/
      cp -r node_modules/@yuuang/* $out/node_modules/@yuuang/
      ln -s ../../packages/fff-node $out/node_modules/@ff-labs/fff-node

      cp packages/fff-node/bin/libfff_c.so $out/target/release/
      touch $out/Cargo.toml

      runHook postInstall
    '';
  };

  pi-usage-extension = pkgs.fetchFromGitHub {
    owner = "tmustier";
    repo = "pi-extensions";
    rev = "a6839e57c0f0d8d534b01e646abce2d6530faf01";
    hash = "sha256-ecS05kVnga1y+OoRoUH7/+WCrQsxgP/q/AcSWAPyO8o=";
  };

  pi-openai = pkgs.fetchFromGitHub {
    owner = "lukasl-dev";
    repo = "pi-openai";
    rev = "14b34130d219158762a27b460d6cc85a667a622e";
    hash = "sha256-Ivxl8/UaEiZtqQA4uM355IVjmgzh2doTdQuXQsfxeVg=";
  };

  pi-exa = pkgs.fetchFromGitHub {
    owner = "joemccann";
    repo = "pi-exa";
    rev = "efbfd05100547ed435f94d4bba1e77919cf9e681";
    hash = "sha256-egzx2BXEbyiOr0F7iuPa8f3QXjkCOvWl4V3GTsA1vyk=";
  };
in
{
  imports = [ inputs.pi.nixosModules.default ];

  options.planet.programs = {
    pi = {
      secrets = {
        opencode = lib.mkOption {
          type = lib.types.path;
          description = "OpenCode API key file";
        };
        exa = lib.mkOption {
          type = lib.types.path;
          description = "Exa API key file";
        };
      };
    };
  };

  config = {
    programs.pi.coding-agent = {
      enable = true;

      rules = builtins.readFile ./AGENTS.md;

      skills = [
        ./skills/github
        ./skills/lightpanda
        ./skills/obsidian
        ./skills/tikzjax
        ./skills/zig

        "${inputs.firn}/home-manager"
        "${inputs.firn}/nix"
        "${inputs.firn}/nvf"

        "${pi-exa}/skills/exa-search"
      ];

      extensions = [
        ./extensions/wakatime.ts
        "${pi-fff}/packages/pi-fff"
        "${pi-usage-extension}/usage-extension"
        "${pi-openai}"
        "${pi-exa}/extensions/index.ts"
      ];

      themes = [ ./themes/catppuccin-mocha.json ];

      environment = {
        OPENCODE_API_KEY = pi.secrets.opencode;
        EXA_API_KEY = pi.secrets.exa;
      };
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "?" ''
        if [ "$#" -eq 0 ]; then
          echo "usage: ? <prompt...>" >&2
          exit 1
        fi

        exec pi \
          -p "$*" \
          --model gpt-5.4-mini \
          --provider openai-codex \
          --thinking medium 
      '')
    ];

    security.apparmor.policies.pi-mono = {
      state = "enforce";
      profile = ''
        abi <abi/4.0>,
        include <tunables/global>

        profile pi-mono "${lib.getExe config.programs.pi.coding-agent.package}" {
          include <abstractions/base>

          allow all,

          audit deny "${pkgs.unstable.sops}/bin/sops" x,
          audit deny "${pkgs.sops}/bin/sops" x,
          audit deny "/etc/sops/age/**" rwklm,
          audit deny "/etc/sops/**" rwklm,

          audit deny "/etc/agenix/identity" rwklm,
          audit deny "/etc/agenix/**" rwklm,

          audit deny "/home/${user.name}/nixos/dns/creds.json" rwklm,

          audit deny "/run/secrets/" r,

          audit deny "/run/agenix/" r,
          audit deny "/run/agenix.d/" r,

          ${deniedAgeSecretRules}

          audit deny "/home/${user.name}/nixos/secrets/**" rwklm,
          audit deny "/home/${user.name}/nixos/sops/**" rwklm,
        }
      '';
    };
  };
}
