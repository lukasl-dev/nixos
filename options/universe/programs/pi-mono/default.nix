{
  inputs,
  pkgs,
  config,
  ...
}:

let
  inherit (config.universe) user;
  inherit (pkgs.stdenv.hostPlatform) system;

  # TODO: add opencode api key: https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/providers.md
  pi-mono = inputs.pi-mono.packages.${system}.coding-agent;
in
{
  security.apparmor.policies.pi-mono = {
    state = "enforce";
    profile = ''
      abi <abi/4.0>,
      include <tunables/global>

      profile pi-mono "${pi-mono}/bin/pi-mono" {
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

  environment.systemPackages = [ pi-mono ];

  systemd.tmpfiles.rules = [
    "d /home/${user.name}/.pi 0755 ${user.name} users - -"
    "d /home/${user.name}/.pi/agent 0755 ${user.name} users - -"
    "L+ /home/${user.name}/.pi/agent/skills - - - - ${./skills}"
  ];
}
