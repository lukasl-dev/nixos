{
  vim.luaConfigPre = # lua
    ''
      vim.filetype.add({
        extension = {
          puml = "plantuml",
          pu = "plantuml",
        },
      })
    '';
}
