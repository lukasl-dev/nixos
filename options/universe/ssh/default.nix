{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.universe) domain user;
in
{
  sops.secrets = {
    "universe/user/ssh/private_keys/default" = {
      owner = user.name;
    };
    "universe/user/ssh/private_keys/g0_complang_tuwien_ac_at" = {
      owner = user.name;
    };
  };

  users.users = {
    root.openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_ed25519.pub)
    ];
    ${user.name}.openssh.authorizedKeys.keys = [
      (builtins.readFile ./id_ed25519.pub)
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = null;
      UseDns = true;
      PermitRootLogin = "yes";
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  environment.systemPackages = [
    # TODO: if tailscale is enabled, use tailscale ssh
    (pkgs.writeShellApplication {
      name = "ssh-pollux";
      text = ''
        ${lib.optionalString config.planet.services.mullvad.enable "mullvad-exclude "}ssh pollux.planets.${domain}
      '';
    })
  ];

  universe.hm = [
    {
      home.file.".ssh/id_ed25519.pub".source = ./id_ed25519.pub;

      programs.ssh = {
        enable = true;

        enableDefaultConfig = false;

        matchBlocks = {
          "*" = {
            identityFile = config.sops.secrets."universe/user/ssh/private_keys/default".path;
          };

          "g0.complang.tuwien.ac.at" = {
            identityFile = config.sops.secrets."universe/user/ssh/private_keys/g0_complang_tuwien_ac_at".path;
            identitiesOnly = true;
          };
        };
      };
    }
  ];
}
