{
  config,
  # pkgs-unstable,
  ...
}:

let
  nvidiaEnabled = config.hardware.nvidia.modesetting.enable;
in
{
  services.ollama = {
    enable = false;

    acceleration = if nvidiaEnabled then "cuda" else false;
    environmentVariables = {
      "OLLAMA_ORIGINS" = "app://obsidian.md*";
    };
  };

  # environment.systemPackages = [
  #   pkgs-unstable.llama-cpp
  # ];
}
