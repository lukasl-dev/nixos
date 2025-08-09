{
  universe.hm = [
    {
      programs.oh-my-posh = {
        enable = true;

        settings = builtins.fromJSON (builtins.readFile ./settings.json);

        enableBashIntegration = true;
        enableZshIntegration = true;
      };
    }
  ];
}
