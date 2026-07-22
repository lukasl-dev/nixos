{ atlas, lib }:

{
  eval =
    traveller:
    (lib.evalModules {
      specialArgs = { inherit atlas; };
      modules = [
        ../travellers
        traveller
      ];
    }).config.traveller;
}
