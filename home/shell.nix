{ pkgs, ... }:

let
  shellAliases = {
    g = "git status";
    gf = "git fetch";
    gfa = "git fetch --all";
    gfp = "git fetch --prune";
    ga = "git add";
    gb = "git branch";
    gc = "git commit";
    gca = "git commit --amend";
    gs = "git switch";
    gst = "git stash";
    gstp = "git stash pop";
    gd = "git diff";
    gl = "git log";
    gg = "git graph";
    gpl = "git pull";
    gpu = "git push";

    cat = "bat";

    bye = "shutdown -h now";
    cya = "reboot";

    woman = "man";
    emacs = "vi";

    files = "yazi";
    f = "yazi";
  };
in
{
  programs.zsh = {
    enable = true;

    shellAliases = shellAliases;

    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    initExtra = ''
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      bindkey "''${key[Up]}" up-line-or-search
    '';
  };

  programs.bash = {
    enable = true;

    shellAliases = shellAliases;
  };

  programs.git =
    let
      username = "lukasl-dev";
    in
    {
      enable = true;

      userEmail = "git@lukasl.dev";
      userName = username;

      delta.enable = true;

      extraConfig = {
        color.ui = true;
        core.editor = "${pkgs.neovim}/bin/nvim";
        github.user = username;
        push.autoSetupRemote = true;
        pull.rebase = true;
        safe.directory = "/nixos";
        url = {
          "ssh://git@github.com/" = {
            insteadOf = "https://github.com/";
          };
        };
      };

      aliases = {
        graph = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
      };
    };

  programs.oh-my-posh = {
    enable = true;

    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = builtins.fromJSON (builtins.readFile ../dots/oh-my-posh/settings.json);
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set-option -g prefix C-a

      set -s escape-time 0
      set-window-option -g mode-keys vi
      set -g mode-keys vi

      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'

      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      set -g default-terminal "alacritty" 
      set-option -sa terminal-overrides ",alacritty*:Tc" 

      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows 1

      set -g allow-passthrough all
      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM
    '';
  };

  programs.zoxide = {
    enable = true;

    enableZshIntegration = true;
    enableBashIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.direnv = {
    enable = true;

    nix-direnv.enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.fastfetch.enable = true;
  programs.fzf.enable = true;
  programs.carapace.enable = true;
  programs.ripgrep.enable = true;
  programs.yazi.enable = true;

  home.packages = [
    pkgs.gh
    pkgs.just
    pkgs.tree
    pkgs.zip
    pkgs.unzip
    pkgs.speedtest-cli
    pkgs.hyperfine
    pkgs.ffmpeg
    pkgs.imagemagick
  ];
}
