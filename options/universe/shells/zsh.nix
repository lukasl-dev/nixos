{
  config,
  pkgs,
  ...
}:

let
  user = config.universe.user;
in
{
  assertions = [
    {
      assertion = user.name != "";
      message = "🌍 Zsh requires 'universe.user.name' to be defined.";
    }
  ];

  programs.zsh.enable = true;

  environment.pathsToLink = [ "/share/zsh" ];

  users.defaultUserShell = pkgs.zsh;

  universe.hm = [
    {
      programs.zsh = {
        enable = true;

        shellAliases = import ./aliases.nix { inherit pkgs; };

        enableCompletion = true;
        syntaxHighlighting.enable = true;
        autosuggestion.enable = true;

        initContent = ''
          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
          bindkey "''${key[Up]}" up-line-or-search
        '';
      };
    }
  ];
}
