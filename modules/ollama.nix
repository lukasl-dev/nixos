{
  services.ollama = {
    enable = false;
    acceleration = "cuda"; # TODO: use false if nvidia is disabled
  };
}
