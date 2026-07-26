{
  fff,
  pi-codex-conversion,
  pkgs,
  ...
}:

let
  pi-fff = pkgs.buildNpmPackage {
    pname = "pi-fff";
    version = "0.7.2";
    src = fff.source;
    npmDepsHash = "sha256-+uk57NmH4I3mHIdNE4xfSPilwWefni5B51jVxxS3OD0=";
    npmInstallFlags = [ "--include=optional" ];
    npmRebuildFlags = [ "--ignore-scripts" ];
    dontNpmBuild = true;

    buildPhase = ''
      runHook preBuild

      npm run build --workspace packages/fff-node

      mkdir -p packages/fff-node/bin
      cp ${fff.package}/lib/libfff_c.so packages/fff-node/bin/

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

  pi-exa = pkgs.fetchFromGitHub {
    owner = "joemccann";
    repo = "pi-exa";
    rev = "efbfd05100547ed435f94d4bba1e77919cf9e681";
    hash = "sha256-egzx2BXEbyiOr0F7iuPa8f3QXjkCOvWl4V3GTsA1vyk=";
  };
in
{
  pi.coding-agent = {
    rules = builtins.readFile ./AGENTS.md;

    themes = [ ./catppuccin-mocha.json ];

    skills = [
      ./skills/github
      ./skills/obsidian
      ./skills/tikzjax
      ./skills/zig
    ];

    extensions = [
      ./extensions/wakatime.ts
      ./extensions/opencode-free.ts
      "${pi-fff}/packages/pi-fff"
      "${pi-usage-extension}/usage-extension"
      "${pi-exa}/extensions/index.ts"
      "${pi-codex-conversion}"
    ];
  };
}
