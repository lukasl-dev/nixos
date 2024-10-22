{ inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    htop
    wget
    curl
    just
  ];

  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  environment.etc."xdg/nvim".source = ../../../dots/nvim;
  environment.variables.XDG_CONFIG_DIRS = [ "/etc/xdg" ];
}
