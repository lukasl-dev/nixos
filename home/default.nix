{ inputs, ... }:

{
  imports = [
    ./editor.nix
    ./shell.nix

    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  programs.home-manager.enable = true;
  home = {
    stateVersion = "24.05"; # TODO: upgrade

    username = "lukas";
    homeDirectory = "/home/lukas";
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };
}
