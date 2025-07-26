{ inputs, ... }:

{
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];
}
