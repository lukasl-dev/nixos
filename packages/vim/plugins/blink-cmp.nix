{
  vim.autocomplete.blink-cmp = {
    enable = true;
    setupOpts = {
      keymap.preset = "default";
      completion.documentation.auto_show = false;
      sources.default = [
        "lsp"
        "path"
        "snippets"
        "buffer"
      ];
      fuzzy.implementation = "prefer_rust";
      signature.enabled = true;
      appearance.nerd_font_variant = "mono";
    };
  };
}
