{ meta, ... }:

{
  imports = [
    ../../../homeModules/editors/neovim.nix

    ../../../homeModules/development/lua.nix
    ../../../homeModules/development/nix.nix
    ../../../homeModules/development/python.nix

    ../../../homeModules/programs/bat.nix
    ../../../homeModules/programs/btop.nix
    ../../../homeModules/programs/direnv.nix
    ../../../homeModules/programs/eza.nix
    ../../../homeModules/programs/fastfetch.nix
    ../../../homeModules/programs/feh.nix
    ../../../homeModules/programs/fzf.nix
    ../../../homeModules/programs/git.nix
    ../../../homeModules/programs/gh.nix
    ../../../homeModules/programs/mpv.nix
    ../../../homeModules/programs/ripgrep.nix
    ../../../homeModules/programs/yazi.nix
    ../../../homeModules/programs/zip.nix
    ../../../homeModules/programs/zoxide.nix

    ../../../homeModules/security/sops.nix
    ../../../homeModules/security/ssh.nix

    ../../../homeModules/shells/oh-my-posh
    ../../../homeModules/shells/television
    ../../../homeModules/shells/tmux
    ../../../homeModules/shells/bash.nix
    ../../../homeModules/shells/zsh.nix

    ../../../homeModules/themes/catppuccin.nix
  ];

  programs.home-manager.enable = true;
  home = {
    stateVersion = meta.stateVersion;

    username = meta.user.name;
    homeDirectory = "/home/${meta.user.name}";
  };
}
