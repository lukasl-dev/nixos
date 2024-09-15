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
}
