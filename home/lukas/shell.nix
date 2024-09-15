{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    enableCompletion = true;

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    initExtra = ''
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      bindkey "''${key[Up]}" up-line-or-search
    '';

    shellAliases = {
      g = "git status";
      gf = "git fetch";
      gfp = "git fetch --prune";
      ga = "git add";
      gb = "git branch";
      gc = "git commit";
      gca = "git commit --amend";
      gs = "git switch";
      gd = "git diff";
      gl = "git log";
      gg = "git graph";
      gpl = "git pull";
      gpu = "git push";

      r = "ranger";

      cat = "bat";

      bye = "shutdown -h now";
      cya = "reboot";
    };
  };

  programs.oh-my-posh = {
    enable = true;

    useTheme = "catppuccin_mocha";
    enableZshIntegration = true;
  };

  programs.zellij = {
    enable = true;
    settings = {
      pane_frames = false;
    };
  };

  programs.git = {
    enable = true;

    delta = {
      enable = true;
    };

    extraConfig = {
      color.ui = true;
      core.editor = "nvim";
      github.user = "lukasl-dev";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };

    userEmail = "git@lukasl.dev";
    userName = "lukasl-dev";

    aliases = {
      graph = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
    };
  };

  programs.zoxide = {
    enable = true;

    enableNushellIntegration = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.direnv = {
    enable = true;

    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  programs.bat.enable = true;
  programs.ranger.enable = true;
  programs.btop.enable = true;
  programs.fastfetch.enable = true;
  programs.fzf.enable = true;
  programs.ripgrep.enable = true;
  programs.mpv.enable = true;
  programs.yt-dlp.enable = true;

  home.packages = [
    pkgs.gh
    pkgs.just
    pkgs.tree
    pkgs.zip
    pkgs.unzip
    pkgs.speedtest-cli
    pkgs.hyperfine
  ];
}
