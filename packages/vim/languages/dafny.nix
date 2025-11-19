{ pkgs, ... }:

{
  vim = {
    extraPackages = with pkgs; [ dafny ];

    lsp.servers.dafny = {
      enable = true;
    };
  };
}
