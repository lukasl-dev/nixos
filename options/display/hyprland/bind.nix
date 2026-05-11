{
  config,
  lib,
  ...
}:

let
  inherit (config.planet.display) hyprland;
in
{
  options.planet.display.hyprland.bind = lib.mkOption {
    type =
      with lib.types;
      listOf (submodule {
        options = {
          keys = lib.mkOption {
            type = str;
            example = "SUPER + Q";
            description = "Hyprland bind keys.";
          };

          dispatcher = {
            lua = lib.mkOption {
              type = nullOr lines;
              default = null;
              example = # lua
                ''hl.dsp.exec_cmd("firefox")'';
              description = "Lua dispatcher expression passed as second argument to hl.bind.";
            };

            execCmd = lib.mkOption {
              type = nullOr str;
              default = null;
              example = "firefox";
              description = "Command to execute via hl.dsp.exec_cmd.";
            };
          };
        };
      });
    default = [ ];
    example = [
      {
        keys = "SUPER + Return";
        dispatcher.execCmd = "ghostty";
      }
      {
        keys = "SUPER, Q";
        dispatcher.lua = # lua
          ''
            function()
              hl.dispatch(hl.dsp.killactive())
            end
          '';
      }
    ];
    description = "Hyprland binds generated as hl.bind(keys, dispatcher).";
  };

  config = lib.mkIf hyprland.enable {
    assertions = map (bind: {
      assertion = (bind.dispatcher.lua != null) != (bind.dispatcher.execCmd != null);
      message = "🪐 Hyprland bind '${bind.keys}' must define exactly one of 'dispatcher.lua' or 'dispatcher.execCmd'.";
    }) hyprland.bind;

    planet.display.hyprland.lua = map (bind: ''
      hl.bind(${builtins.toJSON bind.keys}, ${
        if bind.dispatcher.execCmd != null then
          "hl.dsp.exec_cmd(${builtins.toJSON bind.dispatcher.execCmd})"
        else
          bind.dispatcher.lua
      })
    '') hyprland.bind;
  };
}
