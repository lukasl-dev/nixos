{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.planet.fonts = {
    packages = lib.mkOption {
      type = with lib.types; listOf path;
      default = [ ];
      example = lib.literalExpression "[ pkgs.dejavu_fonts ]";
      description = "List of primary font packages.";
    };
  };

  config = {
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
        ++ config.planet.fonts.packages;
    };
  };
}
