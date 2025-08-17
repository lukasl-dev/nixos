{
  inputs,
  config,
  lib,
  ...
}:

let
  wm = config.planet.wm;
in
{
  options.planet.programs.ghostty = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable ghostty";
    };
  };

  config = lib.mkIf config.planet.programs.ghostty.enable {
    environment.systemPackages = [
      inputs.ghostty.packages.x86_64-linux.default
    ];

    # hjem.users.${user.name}.files.".config/ghostty/config".source = ./config;

    universe.hm = [
      {
        home.file.".config/ghostty/config".source = ./config;
      }
    ];
  };
}
