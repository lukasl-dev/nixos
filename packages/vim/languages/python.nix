{ pkgs, ... }:

{
  vim = {
    extraPackages = with pkgs; [ ruff ];

    languages.python = {
      enable = true;
      lsp.servers = [
        # "ty"
        "basedpyright"
      ];
      format.type = [ "ruff" ];
    };

    formatter.conform-nvim.setupOpts.formatters_by_ft.python = [ "ruff_format" ];

    autocmds = [
      {
        event = [ "FileType" ];
        pattern = [ "python" ];
        desc = "Use sane Python indentation";
        command = "setlocal expandtab autoindent nosmartindent shiftwidth=4 tabstop=4 softtabstop=4 colorcolumn=89";
      }
      {
        event = [ "FileType" ];
        pattern = [ "python" ];
        desc = "Do not reindent current Python line when typing ':'";
        command = "setlocal indentkeys-=: indentkeys-=<:>";
      }
    ];
  };
}
