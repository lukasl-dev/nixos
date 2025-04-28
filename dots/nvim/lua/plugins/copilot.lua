return {
  "zbirenbaum/copilot.lua",

  cmd = "Copilot",
  event = "InsertEnter",

  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
    },

    copilot_model = "gemini-2.5-pro",
  },
}
