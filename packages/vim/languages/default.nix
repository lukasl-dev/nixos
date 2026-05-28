{ pkgs, ... }:

{
  imports = [
    ./assembly.nix
    ./bash.nix
    ./c.nix
    ./dafny.nix
    ./go.nix
    ./haskell.nix
    ./java.nix
    ./just.nix
    ./markdown.nix
    ./nix.nix
    ./python.nix
    ./r.nix
    ./rust.nix
    ./tex.nix
    ./typescript.nix
    ./yaml.nix
    ./zig.nix
  ];

  vim = {
    treesitter.enable = true;

    # FIXME:
    # Bypass broken nvf grammarPlugins (nvf issue #1442).
    # nvf's grammarToPlugin produces directories instead of .so files.
    # Using withPlugins directly on builtGrammars works correctly.
    startPlugins = [
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (
        p: with p; [
          asm
          bash
          c
          cpp
          go
          gomod
          gosum
          gotmpl
          gowork
          haskell
          java
          javascript
          just
          latex
          markdown
          markdown_inline
          nix
          python
          r
          rust
          tsx
          typescript
          yaml
          zig
        ]
      ))
    ];

    lsp.enable = true;

    languages = {
      enableDAP = true;
      enableExtraDiagnostics = true;
      enableTreesitter = true;
    };

    formatter.conform-nvim = {
      enable = true;
      setupOpts.format_on_save = {
        timeout_ms = 20000;
        lsp_fallback = true;
      };
    };

    debugger.nvim-dap = {
      enable = true;
      ui.enable = false;
    };

    extraPlugins = {
      blink-compat = {
        package = pkgs.vimPlugins.blink-compat;
      };
      cmp-dap = {
        package = pkgs.vimPlugins.cmp-dap;
      };
    };
    # extraPlugins = {
    #   nvim-dap-virtual-text = {
    #     package = pkgs.vimPlugins.nvim-dap-virtual-text;
    #     setup = "require('nvim-dap-virtual-text').setup({})";
    #   };
    # };
  };
}
