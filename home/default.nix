{ meta, inputs, ... }:

{
  imports = [
    ./editor.nix
    ./shell.nix

    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  programs.home-manager.enable = true;
  home = {
    stateVersion = "24.11";

    username = meta.user.name;
    homeDirectory = "/home/${meta.user.name}";
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  home.file.".ssh/id_ed25519.pub" = {
    enable = true;
    source = ../dots/ssh/id_ed25519.pub;
    target = ".ssh/id_ed25519.pub";
  };
}
