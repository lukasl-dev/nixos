{ pkgs, ... }:

{
  vim = {
    extraPackages = with pkgs; [ nixfmt-rfc-style ];

    languages.nix.enable = true;

    formatter.conform-nvim.setupOpts.formatters_by_ft.nix = [ "nixfmt" ];
  };
}
