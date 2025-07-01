{ config, ... }:

{
  nix = {
    distributedBuilds = true;
    settings.builders = [ "ssh-ng://pollux?ssh-key=/root/.ssh/id_ed25519" ];

    settings = {
      builders-use-substitutes = true;
    };
  };

  sops.templates."/root/.ssh/id_ed25519" = {
    path = "/root/.ssh/id_ed25519";
    owner = "root";
    content = config.sops.placeholder."ssh/private_key";
  };
}
