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
    # nix-related
    pkgs.nixd
    pkgs.nixfmt-rfc-style

    # go-related
    pkgs.delve

    # erlang-related
    pkgs.erlang
    pkgs.elixir
    pkgs.gleam

    # java-related
    pkgs.zulu21

    # nodejs-related
    pkgs.nodejs

    # python-related
    pkgs.python3
    pkgs.uv

    # rust-related
    pkgs.rustc
    pkgs.clippy
    pkgs.cargo
    pkgs.rustfmt

    # tex-related
    pkgs.texliveFull
    pkgs.graphviz

    # zig-related
    pkgs-unstable.zig

    # miscellaneous
    pkgs.d2
  ];
}
