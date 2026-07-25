{ pkgs, tptp, ... }:

{
  vim.extraPlugins."vim-tptp" = {
    package = pkgs.vimUtils.buildVimPlugin {
      name = "vim-tptp";
      pname = "vim-tptp";
      src = tptp;
    };
  };
}
