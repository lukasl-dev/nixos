{
  vim = {
    utility.oil-nvim = {
      enable = true;
      setupOpts = {
        columns = [
          "icon"
          "permissions"
          "size"
        ];
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "-";
        action = ":Oil<CR>";
        silent = true;
      }
    ];
  };
}
