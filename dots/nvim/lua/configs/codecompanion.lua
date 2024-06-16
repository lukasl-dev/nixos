local options = {
  adapters = {
    ollama = require("codecompanion.adapters").use("ollama", {
      schema = {
        model = {
          default = "phi3:latest",
          -- default = "llama3:latest"
        },
      },
    }),
  },
  strategies = {
    chat = "ollama",
    inline = "ollama",
  },
}

require("codecompanion").setup(options)
