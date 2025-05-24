{ config, ... }:

{
  programs.eza = {
    enable = true;

    git = config.programs.git.enable;
    icons = "auto";

    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;
  };
}
