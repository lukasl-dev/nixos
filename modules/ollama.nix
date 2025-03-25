{
  config,
  pkgs-unstable,
  ...
}:

let
  nvidiaEnabled = config.hardware.nvidia.modesetting.enable;
in
{
  services.ollama = {
    enable = true;

    acceleration = if nvidiaEnabled then "cuda" else false;
    environmentVariables = {
      "OLLAMA_ORIGINS" = "app://obsidian.md*";
    };
  };

  # services.open-webui = {
  #   enable = true;
  #   package = pkgs-unstable.open-webui;
  #   port = 6969;
  #   environment = {
  #     ANONYMIZED_TELEMETRY = "False";
  #     DO_NOT_TRACK = "True";
  #     SCARF_NO_ANALYTICS = "True";
  #     WEBUI_AUTH = "False";
  #   };
  # };
}
