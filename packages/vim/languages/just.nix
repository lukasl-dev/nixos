{ pkgs, ... }:

{
  vim = {
    treesitter.grammars = [
      pkgs.vimPlugins.nvim-treesitter.grammarPlugins.just
    ];
    formatter.conform-nvim.setupOpts.formatters_by_ft.just = [ "just" ];
  };
}
