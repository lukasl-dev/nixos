{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  # neovim
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs-unstable; [
      # Tools
      sqlite
      gcc
      gnumake
      ripgrep

      # Nix
      nixd
      nixfmt-rfc-style

      # Python
      ruff
      uv
      python312Packages.grip
      python312Packages.pylatexenc

      # Rust
      rustc
      cargo

      # Lua
      lua-language-server

      # NodeJS
      nodejs
    ];
  };

  # nvim config directory
  home.file.".config/nvim" = {
    enable = true;
    source = ../dots/nvim;
    target = ".config/nvim";
  };
  # home.file.".config/nvim/lazy-lock.json".source =
  #   config.lib.file.mkOutOfStoreSymlink "${meta.dir}/dots/nvim/lazy-lock.json";
}
