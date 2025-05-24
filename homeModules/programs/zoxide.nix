{ config, ... }:

{
  programs.zoxide = {
    enable = true;

    options = [ "--cmd cd" ];

    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;
  };
}
