{ pkgs, ... }:

{
  imports = [
    # TODO: add host-unspecific modules here
  ];

  environment.systemPackages = with pkgs; [ nixfmt-rfc-style ];
}
