{
  config,
  lib,
  pkgs,
  ...
}:

let
  domain = config.universe.domain;
  user = config.universe.user;
in
{
  sops.secrets."universe/user/ssh/private_key" = {
    owner = user.name;
    path = "/home/${user.name}/.ssh/id_ed25519";
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
    }
  ];
}
