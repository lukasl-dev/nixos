{
  pkgs,
  pkgs-unstable,
  ...
}:

{
  programs.bun = {
    enable = true;
  };

  programs.go = {
    enable = true;
    package = pkgs-unstable.go_1_24;
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
    pkgs-unstable.delve
    pkgs-unstable.gopls

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
    pkgs.python312Packages.pylatexenc
    pkgs.python312Packages.debugpy

    # jupyter
    pkgs.python312Packages.jupyter
    pkgs.python312Packages.jupyterlab
    pkgs.python312Packages.notebook
    pkgs.python312Packages.ipython
    pkgs.python312Packages.ipykernel
    pkgs.python312Packages.matplotlib
    pkgs.python312Packages.seaborn
    pkgs.python312Packages.pandas
    pkgs.python312Packages.numpy
    pkgs.python312Packages.scipy

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

    # git-related
    pkgs.git-lfs

    # obsidian
    pkgs-unstable.markdown-oxide

    # miscellaneous
    pkgs.d2

    # suffering and pain
    pkgs-unstable.jetbrains.idea-ultimate
  ];

  # cargo
  home.file.".cargo/config.toml" = {
    enable = true;
    source = ../../dots/cargo/config.toml;
    target = ".cargo/config.toml";
  };
}
