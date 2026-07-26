{ lib, ... }:

{
  options.traveller.desktop.hyprland.config = lib.mkOption {
    type =
      with lib.types;
      let
        valueType = nullOr (oneOf [
          bool
          int
          float
          str
          path
          (attrsOf valueType)
          (listOf valueType)
        ]);
      in
      attrsOf valueType;

    default = { };
    example = {
      general.gaps_out = 10;
      input.touchpad.natural_scroll = false;
    };
    description = "Traveller overrides passed to hl.config.";
  };
}
