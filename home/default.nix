{
  imports = [ ./shell.nix ];

  programs.home-manager.enable = true;
  home = {
    stateVersion = "24.05"; # TODO: upgrade

    username = "lukas";
    homeDirectory = "/home/lukas";
  };
}
