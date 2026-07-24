{
  atlas,
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (config) planet;
  inherit (pkgs.stdenv.hostPlatform) system;

  lua = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system}.lua5_5;
in
{
  imports = [
    ./monitors.nix
    ./polkit.nix
  ];

  options.planet.desktop.hyprland.lua = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Planet-specific Hyprland Lua configuration.";
  };

  config = lib.mkIf planet.desktop.enable {
    hjem.users = atlas.travellers.forEach planet (
      traveller:
      let
        merged = lib.concatStringsSep "\n\n" (
          lib.filter (lua: lua != "") [
            planet.desktop.hyprland.lua
            traveller.desktop.hyprland.lua
          ]
        );

        checked =
          let
            key = "hyprland-${planet.name}-${traveller.name}";
            source = pkgs.writeText "${key}.lua" (merged traveller);
            name = "${key}-config.lua";
          in
          pkgs.runCommand name { } ''
            cp ${source} "$out"

            # Hyprland 0.55's verifier currently crashes for Lua configurations.
            ${lib.getExe' lua "luac"} -p "$out"
          '';
      in
      {
        xdg.config.files."hypr/hyprland.lua".source = checked;
      }
    );
  };
}
