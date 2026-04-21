{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.universe) user;
  inherit (pkgs.stdenv.hostPlatform) system;

  pi-mono-real = inputs.pi-mono.packages.${system}.coding-agent;

  pi-fff = pkgs.buildNpmPackage {
    pname = "pi-fff";
    version = "0.6.0";
    src = inputs.fff-nvim.outPath;
    npmDepsHash = "sha256-mPoZ5fYcb2PQ/5aDdB5pTfDvfrMyVj2B9VlMfNQjae0=";
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

  pi-mono-models =
    pkgs.runCommand "pi-mono-models.json"
      {
        nativeBuildInputs = [ pkgs.tsx ];
      }
      ''
        tsx ${./models.mjs} \
          ${pi-mono-real.src}/packages/ai/src/models.generated.ts \
          opencode-go > $out
      '';

  pi-mono = pkgs.writeShellScriptBin "pi" ''
    export OPENCODE_API_KEY="$(cat ${config.age.secrets."universe/pi-mono/opencode_api_key".path})"
    exec ${lib.getExe pi-mono-real} \
      -e ${pi-fff}/packages/pi-fff/src/index.ts \
      "$@"
  '';
in
{
  imports = [ inputs.pi-mono.nixosModules.default ];

  security.apparmor.policies.pi-mono = {
    state = "enforce";
    profile = ''
      abi <abi/4.0>,
      include <tunables/global>

      profile pi-mono "${lib.getExe pi-mono}" {
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
        audit deny "/run/secrets/**" r,

        audit deny "/run/agenix/" r,
        audit deny "/run/agenix/**" r,
        audit deny "/run/agenix.d/" r,
        audit deny "/run/agenix.d/**" r,

        audit deny "/home/${user.name}/nixos/secrets/**" rwklm,
        audit deny "/home/${user.name}/nixos/sops/**" rwklm,
      }
    '';
  };

  age.secrets = {
    "universe/pi-mono/opencode_api_key" = {
      rekeyFile = ../../../../secrets/universe/pi-mono/opencode_api_key.age;
      owner = user.name;
      path = "/home/${user.name}/.pi/opencode_api_key";
      symlink = false;
    };
  };

  programs.pi.coding-agent = {
    enable = true;
    package = pi-mono;

    rules = builtins.readFile ./AGENTS.md;

    skills = [
      ./skills/github
      ./skills/home-manager
      ./skills/lightpanda
      ./skills/nixpkgs
      ./skills/nvf
      ./skills/obsidian
      ./skills/tikzjax
      ./skills/zig
    ];

    extensions = [
      ./extensions/openai.ts
      ./extensions/wakatime.ts
      pi-fff
    ];

    themes = [
      ./themes/catppuccin-mocha.json
    ];

    models = pi-mono-models;
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "?" ''
      if [ "$#" -eq 0 ]; then
        echo "usage: ? <prompt...>" >&2
        exit 1
      fi

      exec ${lib.getExe pi-mono} \
        -p "$*" \
        --model gpt-5.4-mini \
        --provider openai-codex \
        --thinking medium 
    '')
  ];
}
