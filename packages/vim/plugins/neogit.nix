{
  vim.git.neogit = {
    enable = true;
    setupOpts =
      let
        signs = {
          add.text = "";
          change.text = "";
          delete.text = "";
          topdelete.text = "";
          changedelete.text = "";
          untracked.text = "";
        };
      in
      {
        current_line_blame = true;
        inherit signs;
        signs_staged = signs;
      };
  };
}
