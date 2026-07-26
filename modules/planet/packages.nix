{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cowsay
    just
    jq
    file
    dysk
    cava
    tree
    man-pages
  ];
}
