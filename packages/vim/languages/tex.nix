{ pkgs, ... }:

let
  package = pkgs.vimUtils.buildVimPlugin {
    name = "vimtex";
    pname = "vimtex";
    src = pkgs.fetchFromGitHub {
      owner = "lervag";
      repo = "vimtex";
      rev = "df8892993c1df79b96c2d237c8a0cbcbf72131da";
      hash = "sha256-OtQZQ1D5Je1dcXkDyUr39JmC42Uf+BVftMqk8ATDHvg=";
    };
    nvimSkipModules = [
      "vimtex.fzf-lua.init"
      "vimtex.snacks.init"
    ];
  };
in
{
  vim = {
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
      ft = [ "tex" "plaintex" ];
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
        pattern = [ "tex" "plaintex" ];
        desc = "Keep TeX indentation simple and stop punctuation-triggered reindent";
        command = "setlocal autoindent nosmartindent indentexpr= indentkeys=!^F";
      }
    ];
  };
}
