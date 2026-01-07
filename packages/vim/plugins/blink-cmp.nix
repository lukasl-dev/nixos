{
  vim.autocomplete.blink-cmp = {
    enable = true;
    setupOpts = {
      keymap.preset = "default";
      completion.documentation.auto_show = false;
      sources = {
        default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ];
        per_filetype = {
          dap-repl = [ "dap" ];
        };
        providers = {
          dap = {
            name = "dap";
            module = "blink.compat.source";
            score_offset = 100;
            opts = { };
          };
        };
      };
      fuzzy.implementation = "prefer_rust";
      signature.enabled = true;
      appearance.nerd_font_variant = "mono";
    };
  };
}
