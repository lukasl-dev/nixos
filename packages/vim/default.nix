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

  vim = {
    utility.nix-develop.enable = true;
  };
}
