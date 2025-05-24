{ pkgs-unstable, ... }:

{
  programs.wireshark = {
    enable = true;
    package = pkgs-unstable.wireshark;
  };
}
