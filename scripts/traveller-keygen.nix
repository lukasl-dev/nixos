{ agenix-rekey, pkgs, ... }:

import ./keygen.nix {
  inherit agenix-rekey pkgs;

  command = "traveller-keygen";
  entity = "traveller";
  entityRoot = "travellers";
  privateRoot = "secrets/universe/travellers";
  publicRoot = "travellers";
  publicRelative = "id_ed25519.pub";
}
