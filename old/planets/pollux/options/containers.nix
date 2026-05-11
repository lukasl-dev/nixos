{ lib, ... }:

{
  options.pollux.containers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf lib.types.deferredModule);
    default = { };
    description = "Extra configuration modules to merge into containers on Pollux.";
  };
}
