{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.planet) wm;
  inherit (wm) hyprland;
  inherit (config.planet.programs) helium;
in
{
  options.planet.programs.helium = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = wm.enable;
      description = "Enable helium browser";
    };
  };

  config = lib.mkIf helium.enable {
    environment.systemPackages = [
      (pkgs.symlinkJoin {
        name = "helium";
        paths = [ pkgs.nur.repos.Ev357.helium ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/helium \
            --add-flags "--enable-unsafe-webgpu" \
            --add-flags "--ozone-platform=x11" \
            --add-flags "--use-angle=vulkan" \
            --add-flags "--enable-features=Vulkan,VulkanFromANGLE${lib.optionalString hyprland.enable ",WaylandLinuxDrmSyncobj"}"
        '';
      })
    ];
  };
}
