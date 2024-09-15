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
      extraGroups = [
        "networkmanager"
        "wheel"
        "docker"
      ];
      shell = pkgs.zsh;
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
