{
  vim = {
    languages.rust.enable = true;

    formatter.conform-nvim.setupOpts.formatters_by_ft.rust = [ "rustfmt" ];
  };
}
