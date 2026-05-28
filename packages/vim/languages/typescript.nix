{ pkgs, ... }:

{
  vim = {
    languages.typescript.enable = true;

    extraPackages = [ pkgs.biome ];

    formatter.conform-nvim.setupOpts.formatters_by_ft = {
      typescript = [ "biome" ];
      javascript = [ "biome" ];
      typescriptreact = [ "biome" ];
      javascriptreact = [ "biome" ];
    };
  };
}
