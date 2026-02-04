{
  vim = {
    languages.zig = {
      enable = true;

      # disable LSP as every project might use different incompatible versions
      # of zls
      lsp.enable = false;
    };

    # enables zls without installing any specific version of zls
    lsp.servers.zls = {
      enable = true;
      cmd = [ "zls" ];
      filetypes = [
        "zig"
        "zir"
      ];
      root_markers = [
        "zls.json"
        "build.zig"
        ".git"
      ];
      workspace_required = false;
    };

    formatter.conform-nvim.setupOpts.formatters_by_ft.zig = [ "zigfmt" ];
  };
}
