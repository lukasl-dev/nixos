{
  inputs,
  pkgs,
  config,
  ...
}:

let
  inherit (config.universe) user;
  inherit (pkgs.stdenv.hostPlatform) system;

  # inherit (pkgs.unstable) github-mcp-server;
  #
  # github-mcp-server-wrapped = pkgs.writeShellScriptBin "github-mcp-server" ''
  #   export GITHUB_PERSONAL_ACCESS_TOKEN="$(cat ${
  #     config.age.secrets."universe/opencode/github_pat".path
  #   })"
  #   exec ${github-mcp-server}/bin/github-mcp-server "$@"
  # '';
  # rime = inputs.rime.packages.${system}.default;

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
}
