{ pkgs, ... }:

let
  package = pkgs.vimUtils.buildVimPlugin {
    name = "vimtex";
    pname = "vimtex";
    src = pkgs.fetchFromGitHub {
      owner = "lervag";
      repo = "vimtex";
      rev = "be9deac3a23eeb145ccf11dd09080795838496ce";
      hash = "sha256-Tx4HQmwM2bRx2e/3vuEsKAYMcLbKYr9tELWjipehxew=";
    };
    nvimSkipModules = [
      "vimtex.fzf-lua.init"
      "vimtex.snacks.init"
    ];
  };
in
{
  vim = {
    extraPackages = with pkgs; [ sioyek ];

    lazy.plugins."vimtex" = {
      inherit package;
      event = [ "BufWinEnter" ];
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
  };
}
