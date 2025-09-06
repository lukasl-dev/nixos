{
  # TODO: enable after home-manager update:

  # universe.hm = [
  #   {
  #     programs.codex = {
  #       enable = true;
  #       custom-instructions = ''
  #         - If you support tool calling, take full advantage of all tools available to you.
  #         - On NixOS, use `nix-shell` or `nix run` to use packages that might not be installed on the system.
  #       '';
  #       settings = {
  #         model_providers = {
  #           ollama = {
  #             name = "Ollama";
  #             base_url = "http://localhost:11434/v1";
  #           };
  #         };
  #         mcp_servers = {
  #           rime = {
  #             command = "nix";
  #             args = [
  #               "run"
  #               "github:lukasl-dev/rime"
  #               "--"
  #               "stdio"
  #             ];
  #           };
  #         };
  #       };
  #     };
  #   }
  # ];
}
