{ meta, inputs, ... }:

{
  imports = [
    ./editor.nix
    ./shell.nix
    ./sops.nix

    inputs.catppuccin.homeModules.catppuccin
  ];

  programs.home-manager.enable = true;
  home = {
    stateVersion = "25.05";

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

  home.file.".cargo/config.toml" = {
    enable = true;
    source = ../dots/cargo/config.toml;
    target = ".cargo/config.toml";
  };
}
