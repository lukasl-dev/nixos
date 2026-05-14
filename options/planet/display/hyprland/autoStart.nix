{
  config,
  lib,
  ...
}:

let
  inherit (config.planet.display) hyprland;
in
{
  options.planet.display.hyprland.autoStart = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [
      "firefox"
      "vesktop"
    ];
    description = "Commands to execute when Hyprland starts.";
  };

  config = lib.mkIf hyprland.enable {
    planet.display.hyprland.on.start = map (
      command: "hl.exec_cmd(${builtins.toJSON command})"
    ) hyprland.autoStart;
  };
}
