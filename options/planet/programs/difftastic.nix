{
  planet.hm = [
    {
      programs.difftastic = {
        enable = true;

        git = {
          enable = true;
          diffToolMode = true;
        };
        # jujutsu.enable = true;
      };
    }
  ];
}
