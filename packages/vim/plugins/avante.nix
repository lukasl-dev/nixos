{
  vim.assistant.avante-nvim = {
    enable = false;
    setupOpts = {
      instructions_file = "AGENTS.md";
      provider = "opencode";
      acp_providers = {
        opencode = {
          command = "opencode";
          args = [ "acp" ];
        };
      };
    };
  };
}
