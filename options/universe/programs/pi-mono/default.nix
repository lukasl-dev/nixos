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

  extensions = builtins.path {
    path = ./extensions;
    name = "pi-mono-extensions";
    filter =
      path: type:
      let
        base = builtins.baseNameOf path;
      in
      base != "node_modules" && (type == "directory" || pkgs.lib.hasSuffix ".ts" base);
  };

  themes = builtins.path {
    path = ./themes;
    name = "pi-mono-themes";
    filter =
      path: type:
      let
        base = builtins.baseNameOf path;
      in
      type == "directory" || pkgs.lib.hasSuffix ".json" base;
  };

  pi-mono-real = inputs.pi-mono.packages.${system}.coding-agent;

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
    exec ${lib.getExe pi-mono-real} "$@"
  '';
in
{
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

  environment.systemPackages = [ pi-mono ];

  systemd.tmpfiles.rules = [
    "d /home/${user.name}/.pi 0755 ${user.name} users - -"
    "d /home/${user.name}/.pi/agent 0755 ${user.name} users - -"
    "L+ /home/${user.name}/.pi/agent/extensions - - - - ${extensions}"
    "L+ /home/${user.name}/.pi/agent/skills - - - - ${./skills}"
    "L+ /home/${user.name}/.pi/agent/themes - - - - ${themes}"
    "L+ /home/${user.name}/.pi/agent/models.json - - - - ${pi-mono-models}"
    "L+ /home/${user.name}/.pi/agent/AGENTS.md - - - - ${./AGENTS.md}"
  ];
}
