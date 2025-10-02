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
  ];
}
