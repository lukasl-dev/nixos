{ config, ... }:

let
  user = config.universe.user;
in
{
  sops.secrets."universe/user/ssh/private_key" = {
    owner = user.name;
    path = "/home/${user.name}/.ssh/id_ed25519";
  };

  # hjem.users.${user.name}.files.".ssh/id_ed25519.pub".source = ./id_ed25519.pub;

  universe.hm = [
    {
      home.file.".ssh/id_ed25519.pub".source = ./id_ed25519.pub;
    }
  ];
}
