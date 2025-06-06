local rtp = vim.api.nvim_list_runtime_paths()
local library_paths = {
  vim.fn.expand "$VIMRUNTIME/lua",
  vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
}
for _, path in ipairs(rtp) do
  local lua_path = path .. "/lua"
  if vim.fn.isdirectory(lua_path) == 1 then
    table.insert(library_paths, lua_path)
  end
end

return {
  config = {
    settings = {
      Lua = {
        diagnostics = {
          runtime = { version = "Lua 5.1" },
          globals = {
            "bit", "vim", "it", "describe", "before_each", "after_each",
          },
        },
        workspace = {
          library = library_paths,
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
      },
    },
  }
}
