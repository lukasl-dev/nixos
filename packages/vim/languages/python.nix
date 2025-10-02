{
  vim = {
    languages.python = {
      enable = true;
      lsp.server = "pyright";
    };

    formatter.conform-nvim.setupOpts.formatters_by_ft.python = [ "ruff_format" ];
  };
}
