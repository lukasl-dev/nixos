{ pkgs, ... }:

{
  vim = {
    extraPackages = with pkgs; [ ruff ];

    languages.python = {
      enable = true;
      lsp.servers = [ "pyright" ];
    };

    formatter.conform-nvim.setupOpts.formatters_by_ft.python = [ "ruff_format" ];
  };
}
