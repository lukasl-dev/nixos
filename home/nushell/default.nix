{
  programs.nushell = {
    enable = true;

    configFile.source = ../../dots/nushell/config.nu;
    envFile.source = ../../dots/nushell/env.nu;

    shellAliases = {
      # git
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

      # pass
      p = "pass";

      # ranger
      r = "ranger";

      # bat
      cat = "bat";

      "bye" = "shutdown -h now";
    };
  };

  home.file.".config/nushell/themes" = {
    enable = true;
    source = ../../dots/nushell/themes;
    target = ".config/nushell/themes";
  };
}
