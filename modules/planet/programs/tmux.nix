{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) catppuccin;

  windowStatus =
    "#[fg=#{@thm_crust},bg=#{@thm_overlay_2}] #I "
    + "#[fg=#{@thm_fg},bg=#{@thm_surface_0}] #W ";

  currentStatus =
    "#[fg=#{@thm_crust},bg=#{@thm_mauve}] #I "
    + "#[fg=#{@thm_fg},bg=#{@thm_surface_1}] #W ";

  wlCopy = lib.getExe' pkgs.wl-clipboard "wl-copy";
in
{
  programs.tmux = {
    enable = true;
    plugins = [ catppuccin.sources.tmux ];

    extraConfigBeforePlugins = ''
      set -g @catppuccin_flavor ${lib.escapeShellArg catppuccin.flavor}
    '';

    extraConfig = ''
      set-option -g prefix C-a

      set-option -g set-titles on
      set-option -g set-titles-string '#W'

      set -g window-status-format ${lib.escapeShellArg windowStatus}
      set -g window-status-current-format ${lib.escapeShellArg currentStatus}

      set-window-option -g automatic-rename off
      set-window-option -g allow-rename off
      set -g allow-set-title off

      set -s escape-time 0
      set-window-option -g mode-keys vi
      set -g mode-keys vi

      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel '${wlCopy}'

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

      set -g extended-keys on
      set -g extended-keys-format csi-u
    '';
  };
}
