{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
in
{
  options.planet.desktop.fonts = lib.mkOption {
    type = with lib.types; listOf path;
    default = [ ];
    example = lib.literalExpression "[ pkgs.dejavu_fonts ]";
    description = "List of primary font packages.";
  };

  config = lib.mkIf planet.desktop.enable {
    fonts = {
      enableDefaultPackages = true;

      packages =
        with pkgs;
        [
          nerd-fonts.jetbrains-mono
          nerd-fonts.space-mono

          helvetica-neue-lt-std
          geist-font
        ]
        ++ planet.desktop.fonts;
    };
  };
}
