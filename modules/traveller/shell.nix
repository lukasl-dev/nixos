{ lib, ... }:

{
  options.traveller.shell.aliases = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    description = "Shell aliases specific to this traveller.";
  };
}
