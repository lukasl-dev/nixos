{ pkgs, inputs, ... }:

{
  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # TODO: python 3 via NixOS

  home.file.".config/nvim" = {
    enable = true;
    source = ../../dots/nvim;
    target = ".config/nvim";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
