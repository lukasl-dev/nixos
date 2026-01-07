{ pkgs, ... }:

{
  imports = [
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

    lsp = {
      enable = true;
      lspconfig.enable = true;
    };

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
