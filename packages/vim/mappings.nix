# map("n", "gd", vim.lsp.buf.definition, { silent = true })

{
  vim.keymaps = [
    {
      mode = "n";
      key = "<C-j>";
      action = ":m .+1<CR>==";
      silent = true;
      desc = "Move line down";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = ":m .-2<CR>==";
      silent = true;
      desc = "Move line up";
    }
    {
      mode = "n";
      key = "gd";
      lua = true;
      action = # lua
        ''
          vim.lsp.buf.definition
        '';
      silent = true;
      desc = "Go to definition [LSP]";
    }
    # {
    #   mode = "n";
    #   key = "gd";
    #   action = ":m .-2<CR>==";
    #   silent = true;
    #   desc = "Move line up";
    # }
  ];
}
