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

    # extraPackages = with pkgs-unstable; [
    #   # Tools
    #   sqlite
    #   gcc
    #   gnumake
    #   ripgrep
    #
    #   # Nix
    #   nixd
    #   nixfmt-rfc-style
    #
    #   # Python
    #   pyright
    #   ruff
    #   uv
    #   python312Packages.grip
    #   python312Packages.pylatexenc
    #
    #   # Rust
    #   rustc
    #   clippy
    #   cargo
    #   rustfmt
    #
    #   # Go
    #   delve
    #   gopls
    #
    #   # Lua
    #   lua-language-server
    #
    #   # JavaScript / TypeScript
    #   nodejs
    #   nodePackages.typescript-language-server
    #   tailwindcss-language-server
    # ];
  };

  # nvim config directory
  home.file.".config/nvim" = {
    enable = true;
    source = ../dots/nvim;
    target = ".config/nvim";
  };
}
