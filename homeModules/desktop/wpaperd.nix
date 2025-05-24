{
  services.wpaperd = {
    enable = true;
    settings = {
      default = {
        duration = "5m";
        mode = "center";
        sorting = "random";
      };
      any = {
        path = ../../wallpapers;
      };
    };
  };
}
