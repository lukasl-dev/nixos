{ meta, ... }:

{
  imports = [ ../../shared/nixos ];

  networking.domain = "nodes.${meta.domain}";
}
