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
      mode = "v";
      key = "<C-j>";
      action = ":m '>+1<CR>gv=gv";
      silent = true;
      desc = "Move lines up";
    }
    {
      mode = "n";
      key = "<C-k>";
      action = ":m .-2<CR>==";
      silent = true;
      desc = "Move line up";
    }
    {
      mode = "v";
      key = "<C-k>";
      action = ":m '<-2<CR>gv=gv";
      silent = true;
      desc = "Move lines up";
    }
  ];
}
