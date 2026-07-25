{
  vim.luaConfigPre = # lua
    ''
      vim.filetype.add({
        extension = {
          puml = "plantuml",
          pu = "plantuml",
          mdx = "markdown",
          templ = "templ",
        },
        {
          filename = {
            justfile = "just",
          },
        },
      })
    '';
}
