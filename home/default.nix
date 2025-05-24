{ meta, ... }:

{
  imports = [
    ./shell.nix

    ../homeModules/editors/neovim.nix

    ../homeModules/programs/bat.nix
    ../homeModules/programs/btop.nix
    ../homeModules/programs/direnv.nix
    ../homeModules/programs/eza.nix
    ../homeModules/programs/fastfetch.nix
    ../homeModules/programs/fzf.nix
    ../homeModules/programs/git.nix
    ../homeModules/programs/ripgrep.nix
    ../homeModules/programs/yazi.nix
    ../homeModules/programs/zip.nix
    ../homeModules/programs/zoxide.nix

    ../homeModules/security/sops.nix

    ../homeModules/shells/oh-my-posh
    ../homeModules/shells/tmux
    ../homeModules/shells/bash.nix
    ../homeModules/shells/zsh.nix

    ../homeModules/themes/catppuccin.nix
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
