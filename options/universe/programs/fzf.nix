{
  universe.hm = [
    {
      programs.fzf = {
        enable = true;

        tmux.enableShellIntegration = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
    }
  ];
}
