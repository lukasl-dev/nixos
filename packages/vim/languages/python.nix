{ pkgs, ... }:

{
  vim = {
    extraPackages = with pkgs; [ ruff ];

    languages.python = {
      enable = true;
      lsp.servers = [
        # "ty"
        "pyright"
      ];
      format.type = [ "ruff" ];
    };

    formatter.conform-nvim.setupOpts.formatters_by_ft.python = [ "ruff_format" ];
  };
}
