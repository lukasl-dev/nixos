{ inputs, pkgs, ... }:

{
  # neovim
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # nvim config directory
  home.file.".config/nvim" = {
    enable = true;
    source = ../dots/nvim;
    target = ".config/nvim";
  };
}
