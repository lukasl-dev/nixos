{ atlas, lib }:

let
  eval =
    traveller:
    (lib.evalModules {
      specialArgs = { inherit atlas; };
      modules = [
        ../modules/traveller
        traveller
      ];
    }).config.traveller;

  all =
    planet:
    map (assignment: eval assignment.traveller) (
      [ planet.steward ] ++ planet.travellers
    );
in
{
  inherit eval all;

  forEach =
    planet: f:
    lib.listToAttrs (
      map (traveller: {
        name = traveller.user.name;
        value = f traveller;
      }) (all planet)
    );
}
