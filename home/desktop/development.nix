{ pkgs, pkgs-unstable, ... }:

{
  programs.bun = {
    enable = true;
  };

  programs.go = {
    enable = true;
    package = pkgs-unstable.go_1_23;
  };

  # ocaml package manager
  programs.opam = {
    enable = true;

    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  home.packages = [
    # nix-related
    pkgs.nixd
    pkgs.nixfmt-rfc-style

    pkgs-unstable.gnumake
    pkgs-unstable.gcc

    # go-related
    pkgs.delve
    pkgs.gopls

    # erlang-related
    pkgs.erlang
    pkgs.elixir
    pkgs.gleam

    # java-related
    pkgs.zulu21

    # scala-related
    pkgs-unstable.scala
    pkgs-unstable.sbt
    pkgs-unstable.metals
    pkgs-unstable.coursier

    # nodejs-related
    pkgs.nodejs

    # python-related
    pkgs.python3
    pkgs.uv
    pkgs.python312Packages.grip

    # rust-related
    pkgs.rustc
    pkgs.clippy
    pkgs.cargo
    pkgs.rustfmt

    # tex-related
    pkgs.texliveFull
    pkgs.graphviz
    pkgs.inkscape

    # zig-related
    pkgs-unstable.zig

    # elm-related
    pkgs-unstable.elmPackages.elm

    # haskell-related
    pkgs.ghc
    pkgs.haskell-language-server

    # ocaml-related
    pkgs-unstable.ocaml
    pkgs-unstable.ocamlPackages.lsp
    pkgs-unstable.ocamlPackages.ocamlformat
    pkgs-unstable.ocamlPackages.utop

    # miscellaneous
    pkgs.d2
  ];
}
