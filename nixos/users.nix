{ pkgs, ... }:

{
  users.users = {
    lukas = {
      isNormalUser = true;
      description = "Lukas Leeb";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker" # TODO: configurable
      ];
      shell = pkgs.nushell; # TODO: configurable
    };
  };
}
