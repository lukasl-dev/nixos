{ atlas, lib }:

{
  eval =
    traveller:
    (lib.evalModules {
      specialArgs = { inherit atlas; };
      modules = [
        ../modules/traveller
        traveller
      ];
    }).config.traveller;
}
