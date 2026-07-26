{ agenix-rekey, pkgs, ... }:

import ./keygen.nix {
  inherit agenix-rekey pkgs;

  command = "planet-keygen";
  entity = "planet";
  entityRoot = "planets";
  privateRoot = "secrets/planets";
  publicRoot = "secrets/planets";
  publicRelative = "keys/public.pub";
}
