{ pkgs, ... }:

{
  vim = {
    extraPackages = with pkgs; [
      gofumpt
      gotools

      golangci-lint
      golangci-lint-langserver
    ];

    languages.go.enable = true;

    formatter.conform-nvim.setupOpts.formatters_by_ft.go = [
      "goimports"
      "gofmt"
    ];

    lsp.servers.golangci_lint_ls.enable = true;
  };
}
