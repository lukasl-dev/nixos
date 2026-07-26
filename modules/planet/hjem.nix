{ inputs, ... }:

{
  imports = [ inputs.hjem.nixosModules.default ];

  hjem.extraModules = [ inputs.hjem-rum.hjemModules.default ];
}
