{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    extraConfig = ''
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

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 8;
          y = 8;
        };
      };
      shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [
          "-l"
          "-c"
          "tmux attach-session ; new-window || tmux"
        ];
      };
    };
  };

  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMono";
    font.size = 11;
    extraConfig = ''
      window_padding_width 8
      confirm_os_window_close 0
    '';
  };

  programs.yazi = {
    enable = true;
  };
}
