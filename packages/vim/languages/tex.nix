{
  lib,
  pkgs,
  vimtex,
  ...
}:

let
  package = pkgs.vimUtils.buildVimPlugin {
    name = "vimtex";
    pname = "vimtex";
    src = vimtex;
    nvimSkipModules = [
      "vimtex.fzf-lua.init"
      "vimtex.snacks.init"
    ];
  };
in
{
  vim = {
    treesitter.grammars = [
      pkgs.vimPlugins.nvim-treesitter.grammarPlugins.latex
    ];

    extraPackages = [
      (pkgs.symlinkJoin {
        name = "sioyek";
        paths = [ pkgs.sioyek ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/sioyek \
            --set QT_QPA_PLATFORM xcb
        '';
      })
    ];

    lazy.plugins."vimtex" = {
      inherit package;
      ft = [
        "tex"
        "plaintex"
      ];
    };

    globals = {
      vimtex_compiler_latexmk.options = [
        "-lualatex"
        "-silent"
        "-synctex=1"
        "-shell-escape"
        "-interaction=nonstopmode"
      ];
      vimtex_view_method = "sioyek";
    };

    autocmds = [
      {
        event = [ "FileType" ];
        pattern = [
          "tex"
          "plaintex"
        ];
        desc = lib.concatStrings [
          "Keep TeX indentation simple and stop "
          "punctuation-triggered reindent"
        ];
        command = lib.concatStrings [
          "setlocal autoindent nosmartindent "
          "indentexpr= indentkeys=!^F"
        ];
      }
    ];
  };
}
