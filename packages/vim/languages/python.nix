{
  vim = {
    languages.python = {
      enable = true;
      lsp.servers = [ "pyright" ];
    };

    formatter.conform-nvim.setupOpts.formatters_by_ft.python = [ "ruff_format" ];
  };
}
