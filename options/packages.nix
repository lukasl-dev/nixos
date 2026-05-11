{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    cowsay
    hyperfine
    just
    jq
    file
    dysk
    cava
    tree
    man-pages
  ];
}
