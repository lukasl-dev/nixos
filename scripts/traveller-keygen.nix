{ agenix-rekey, pkgs, ... }:

import ./keygen.nix {
  inherit agenix-rekey pkgs;

  command = "traveller-keygen";
  entity = "traveller";
  entityRoot = "travellers";
  privateRoot = "secrets/travellers";
  publicRoot = "secrets/travellers";
  publicRelative = "keys/public.pub";
}
