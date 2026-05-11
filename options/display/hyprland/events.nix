{
  config,
  lib,
  ...
}:

let
  inherit (config.planet.display) hyprland;
in
{
  options.planet.display.hyprland = {
    on = {
      start = lib.mkOption {
        type = lib.types.listOf lib.types.lines;
        default = [ ];
        example = [
          # lua
          ''hl.exec_cmd("firefox")''
        ];
        description = "Lua lines to include in the hyprland.start callback.";
      };
    };
  };

  config = lib.mkIf hyprland.enable {
    planet.display.hyprland.lua = lib.optional (hyprland.on.start != [ ]) (
      let
        start = lib.concatMapStringsSep "\n" (line: "  ${line}") hyprland.on.start;
      in
      # lua
      ''
        hl.on("hyprland.start", function ()
        ${start}
        end)
      ''
    );
  };
}
