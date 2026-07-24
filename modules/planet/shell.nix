{
  atlas,
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;

  renderAlias =
    name: command:
    let
      escapedName = lib.escapeShellArg name;
      escapedCommand = lib.escapeShellArg command;
    in
    "alias ${escapedName}=${escapedCommand}";

  renderAliases =
    aliases: lib.concatStringsSep "\n" (lib.mapAttrsToList renderAlias aliases);
in
{
  options.planet.shell.aliases = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    description = "Shell aliases shared by configured shells.";
  };

  config = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      interactiveShellInit = # bash
        ''
          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        '';
    };

    users.defaultUserShell = pkgs.zsh;

    environment = {
      pathsToLink = [ "/share/zsh" ];
      variables.SHELL = lib.getExe pkgs.zsh;
    };

    hjem.users = atlas.travellers.forEach planet (
      traveller:
      let
        aliases = planet.shell.aliases // traveller.shell.aliases;
        aliasConfig = renderAliases aliases;
      in
      {
        rum.programs.zsh = {
          enable = true;
          package = null;
          initConfig = aliasConfig;
        };

        files.".bashrc".text = ''
          if [[ -f /etc/bashrc ]]; then
            source /etc/bashrc
          fi

          ${aliasConfig}
        '';
      }
    );
  };
}
