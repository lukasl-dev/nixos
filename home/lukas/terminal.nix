{ pkgs, ... }:

{
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
    font.name = "SpaceMono";
    font.size = 12;
    extraConfig = ''
      window_padding_width 8
      confirm_os_window_close 0
    '';
  };

  programs.yazi = {
    enable = true;
  };
}
