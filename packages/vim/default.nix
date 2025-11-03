# https://notashelf.github.io/nvf/
# https://notashelf.github.io/nvf/options.html

{
  imports = [
    ./languages
    ./plugins
    ./filetypes.nix

    ./clipboard.nix
    ./git.nix
    ./mappings.nix
    ./options.nix
    ./perf.nix
    ./theme.nix
  ];

  # vim = {
  #   # lsp = {
  #   #   lspsaga = {
  #   #     enable = true;
  #   #     setupOpts = {
  #   #       symbol_in_winbar.enable = false;
  #   #       lightbulb.enable = false;
  #   #     };
  #   #   };
  #   # };
  #
  #   # utility = {
  #   #   motion = {
  #   #     leap.enable = true;
  #   #   };
  #   # };
  # };
}
