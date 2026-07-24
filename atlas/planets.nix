{
  atlas,
  inputs,
  lib,
}:

{
  eval =
    {
      system ? "x86_64-linux",
      planet,
    }:
    let
      evaluated = lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit atlas inputs;
        };
        modules = [
          ../modules/planet
          planet
          {
            nixpkgs.overlays = [ atlas.overlays.default ];
            planet.name = builtins.baseNameOf (toString planet);
          }
        ];
      };
    in
    evaluated.extendModules {
      modules = evaluated.config.planet.modules;
    };
}
