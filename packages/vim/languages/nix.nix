{
  vim = {
    languages.nix.enable = true;

    formatter.conform-nvim.setupOpts.formatters_by_ft.nix = [ "nixfmt" ];
  };
}
