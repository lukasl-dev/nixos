{
  programs.nushell = {
    enable = true;

    configFile.source = ./config.nu;
    envFile.source = ./env.nu;

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

      p = "pass";

      r = "ranger";

      cat = "bat";

      bye = "shutdown -h now";
      cya = "reboot";
    };
  };

  home.file.".config/nushell/themes" = {
    enable = true;
    source = ./themes;
    target = ".config/nushell/themes";
  };
}
