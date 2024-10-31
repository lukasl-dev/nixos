{ pkgs, ... }:

{
  users.users = {
    root = {
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ (builtins.readFile ../../../dots/ssh/id_ed25519.pub) ];
    };

    lukas = {
      isNormalUser = true;
      description = "Lukas Leeb";
      initialPassword = "lukas";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [ (builtins.readFile ../../../dots/ssh/id_ed25519.pub) ];
    };
  };
}
