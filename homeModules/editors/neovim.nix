{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
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

  home.file.".config/nvim" = {
    enable = true;
    source = ../../dots/nvim;
    target = ".config/nvim";
  };
}
