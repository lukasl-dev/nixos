{ pkgs, ... }:

{
  imports = [
    ./assembly.nix
    ./bash.nix
    ./c.nix
    ./dafny.nix
    ./go.nix
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
        lsp_format = "fallback";
      };
    };

    debugger.nvim-dap = {
      enable = true;
      ui.enable = false;
    };

    extraPlugins.cmp-dap.package = pkgs.vimPlugins.cmp-dap;
  };
}
