{
  config,
  pkgs,
  ...
}:

let
  user = config.universe.user;
in
{
  assertions = [
    {
      assertion = user.name != "";
      message = "🌍 Zsh requires 'universe.user.name' to be defined.";
    }
  ];

  programs.zsh.enable = true;

  environment.pathsToLink = [ "/share/zsh" ];

  users.defaultUserShell = pkgs.zsh;

  universe.hm = [
    {
      programs.zsh = {
        enable = true;

        shellAliases = import ./aliases.nix { inherit pkgs; };

        enableCompletion = true;
        syntaxHighlighting.enable = true;
        autosuggestion.enable = true;

        initContent = ''
          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

          function zvm_after_init() {
            zvm_bindkey viins '^R' fzf-history-widget
            zvm_bindkey vicmd '^R' fzf-history-widget
          }

          bindkey "''${key[Up]}" up-line-or-search

          # Allow the `?` prompt shortcut to be looked up as a command instead
          # of failing as an unmatched glob.
          setopt nonomatch

          autoload -Uz add-zsh-hook

          _tmux_auto_rename_window() {
            [[ -n "$TMUX" ]] || return 0

            local cmd_override="$1"
            local current_name last_auto_name pane_command pane_dir desired_name
            local -a cmd_words

            current_name="$(tmux display-message -p '#{window_name}' 2>/dev/null)" || return 0
            last_auto_name="$(tmux show-window-options -v '@pi-auto-name' 2>/dev/null || true)"
            pane_dir="$(tmux display-message -p '#{b:pane_current_path}' 2>/dev/null)" || return 0

            if [[ -n "$cmd_override" ]]; then
              cmd_words=(''${(z)cmd_override})
              pane_command="''${cmd_words[1]:t}"
            else
              pane_command="$(tmux display-message -p '#{pane_current_command}' 2>/dev/null)" || return 0
            fi

            [[ -n "$pane_command" ]] || pane_command="zsh"

            if [[ -n "$last_auto_name" && "$current_name" != "$last_auto_name" ]]; then
              return 0
            fi

            if [[ "$pane_command" == "zsh" ]]; then
              desired_name="$pane_dir"
            else
              desired_name="$pane_dir: $pane_command"
            fi

            [[ "$current_name" == "$desired_name" ]] && return 0

            tmux rename-window "$desired_name"
            tmux set-window-option -q @pi-auto-name "$desired_name"
          }

          _tmux_preexec() {
            _tmux_auto_rename_window "$1"
          }

          _tmux_precmd() {
            _tmux_auto_rename_window
          }

          add-zsh-hook preexec _tmux_preexec
          add-zsh-hook precmd _tmux_precmd
        '';
      };
    }
  ];
}
