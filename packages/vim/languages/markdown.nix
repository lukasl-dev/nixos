{ pkgs, lib, ... }:

{
  vim = {
    languages.markdown = {
      enable = true;
      extensions = {
        render-markdown-nvim.enable = true;
      };
    };

    extraPackages = [ pkgs.markdown-oxide ];
    lsp.servers = {
      # slow as fuck (or I did something wrong)
      marksman.enable = lib.mkForce false;

      markdown-oxide = {
        enable = true;
        filetypes = [
          "markdown"
          "markdown.mdx"
        ];
        cmd = [ "${pkgs.markdown-oxide}/bin/markdown-oxide" ];
        root_markers = [
          ".git"
          ".obsidian"
          "quartz.config.ts"
        ];
      };
    };

  };
}
