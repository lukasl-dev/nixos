{ lib, ... }:

{
  options.traveller.desktop.hyprland.lua = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Traveller-specific Hyprland Lua configuration.";
  };
}
