return {
  cmd = { "jdtls" },
  init_options = {
    jvm_args = {
      "-javaagent:$HOME/.local/share/java/lombok.jar"
    },
    workspace = vim.fn.expand "$HOME/.cache/jdtls/workspace"
  },
}
