{ meta, inputs, ... }:

{
  imports = [
    ./shell.nix

    ../homeModules/editors/neovim.nix

    ../homeModules/security/sops.nix
    ../homeModules/shells/zsh.nix
  ];

  programs.home-manager.enable = true;
  home = {
    stateVersion = meta.stateVersion;

    username = meta.user.name;
    homeDirectory = "/home/${meta.user.name}";
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
