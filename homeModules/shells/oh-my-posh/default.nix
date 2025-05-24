{ config, ... }:

{
  programs.oh-my-posh = {
    enable = true;

    settings = builtins.fromJSON (builtins.readFile ./settings.json);

    enableBashIntegration = config.programs.bash.enable;
    enableZshIntegration = config.programs.zsh.enable;
  };
}
