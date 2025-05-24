{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    shellAliases = import ./aliases.nix;

    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    initContent = ''
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      bindkey "''${key[Up]}" up-line-or-search
    '';
  };
}
