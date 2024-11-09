{ inputs, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    htop
    wget
    curl
    just
    zig
    python3
    uv
  ];

  programs.neovim = {
    enable = true;
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
}
