{ lib, ... }:

let
  baseDisabled = [
    "2html_plugin"
    "tohtml"
    "getscript"
    "getscriptPlugin"
    "gzip"
    "logipat"
    "matchit"
    "matchparen"
    "netrw"
    "netrwPlugin"
    "netrwSettings"
    "netrwFileHandlers"
    "rrhelper"
    "spellfile_plugin"
    "tar"
    "tarPlugin"
    "tutor"
    "vimball"
    "vimballPlugin"
    "zip"
    "zipPlugin"
  ];

  aggressiveDisabled = [
    # "syntax"
    # "synmenu"
    # "optwin"
    # "compiler"
    # "bugreport"
    # "ftplugin"
  ];

  disabled = baseDisabled ++ aggressiveDisabled;

  globalsDisabled = builtins.listToAttrs (
    map (n: {
      name = "loaded_${n}";
      value = 1;
    }) disabled
  );
in
{
  vim = {
    globals = globalsDisabled;

    withPython3 = lib.mkDefault false;
    withRuby = lib.mkDefault false;
    withNodeJs = lib.mkDefault false;

    luaConfigRC.no_intro = lib.nvim.dag.entryAnywhere ''
      vim.opt.shortmess:append("I")
    '';
    luaConfigRC.hide_eob = lib.nvim.dag.entryAnywhere ''
      vim.opt.fillchars:append({ eob = " " })
    '';
  };
}
