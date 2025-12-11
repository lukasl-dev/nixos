{ lib, ... }:

{
  planet.wm.hyprland.bindings = lib.mkBefore [
    {
      keys = [ "Space" "Backspace" ];
      params = "caelestia shell drawers toggle launcher";
    }
  ];
}
