return {
  "lervag/vimtex",
  lazy = false,

  config = function()
    vim.g.vimtex_compiler_latexmk = {
      options = {
        "-lualatex",
        "-silent",
        "-synctex=1",
        "-shell-escape",
        "-interaction=nonstopmode",
      },
    }

    vim.g.vimtex_view_method = "sioyek"
  end,
}
