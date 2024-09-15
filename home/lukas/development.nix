{ pkgs, pkgs-unstable, ... }:

{
  programs.bun = {
    enable = true;
  };

  programs.go = {
    enable = true;
    package = pkgs-unstable.go_1_23;
  };

  home.packages = [
    pkgs.erlang
    pkgs.elixir
    pkgs.gleam

    pkgs.zulu21

    pkgs.nodejs

    pkgs.python3
    pkgs.uv

    pkgs.rustc
    pkgs.clippy
    pkgs.cargo
    pkgs.rustfmt

    pkgs.graphviz
    pkgs.texliveFull

    pkgs-unstable.zig
  ];
}
