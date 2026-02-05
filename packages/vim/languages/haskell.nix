{ pkgs, lib, ... }:

{
  vim = {
    languages.haskell.enable = true;

    extraPackages = with pkgs; [
      haskell-language-server
      ormolu
      haskellPackages.cabal-fmt
    ];

    # HLS has a known issue where hlint diagnostics cause it to crash on GHC 9.10+
    # We disable hlint diagnostics in the haskell-tools.nvim configuration.
    # See: https://github.com/haskell/haskell-language-server/issues/4674
    #
    # We also strip 'enable', 'filetypes' and 'root_dir' from the hls config table,
    # as nvf accidentally leaks these Nix-side internal options into the Lua config,
    # which causes haskell-tools.nvim to complain about unrecognized keys.
    luaConfigRC.haskell-tools-hlint-fix = lib.nvim.dag.entryAfter [ "haskell-tools-nvim" ] ''
      if vim.g.haskell_tools then
        local ht = vim.g.haskell_tools
        ht.hls = vim.tbl_deep_extend('force', ht.hls or {}, {
          settings = {
            haskell = {
              plugin = {
                hlint = { globalOn = false },
              },
            },
          },
        })

        -- Remove keys that haskell-tools.nvim does not recognize
        ht.hls.enable = nil
        ht.hls.filetypes = nil
        ht.hls.root_dir = nil

        vim.g.haskell_tools = ht
      end
    '';
  };
}
