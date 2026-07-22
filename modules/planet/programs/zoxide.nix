{
  programs.zoxide = {
    enable = true;
    flags = [ "--cmd cd" ];

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableFishIntegration = false;
    enableXonshIntegration = false;
  };
}
