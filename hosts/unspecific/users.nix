{
  inputs,
  pkgs-unstable,
  pkgs,
  ...
}:

{
  users.users = {
    lukas = {
      isNormalUser = true;
      description = "Lukas Leeb";
      initialPassword = "lukas";
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
      shell = pkgs.nushell;
      openssh.authorizedKeys.keys = [ (builtins.readFile ../../dots/ssh/id_ed25519.pub) ];
    };
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs pkgs-unstable;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
