{
  programs.direnv = {
    enable = true;

    nix-direnv.enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = false;
    enableXonshIntegration = false;
  };
}
