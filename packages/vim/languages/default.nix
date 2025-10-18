{
  imports = [
    ./bash.nix
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
        # Increase to accommodate slower formatters (e.g., IntelliJ CLI on first run)
        timeout_ms = 20000;
        lsp_fallback = true;
      };
    };
  };
}
