{ pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs-unstable; [
    nixd
    nixfmt-rfc-style
  ];
}
