{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.planet.development.python = {
    enable = lib.mkEnableOption "Enable python";
  };

  config = lib.mkIf config.planet.development.python.enable {
    environment.systemPackages = with pkgs.unstable; [
      python3
      uv
      python312Packages.grip
      python312Packages.pylatexenc
      python312Packages.debugpy

      python312Packages.jupyter
      python312Packages.jupyterlab
      python312Packages.notebook
      python312Packages.ipython
      python312Packages.ipykernel
      python312Packages.matplotlib
      python312Packages.seaborn
      python312Packages.pandas
      python312Packages.numpy
      python312Packages.scipy
    ];
  };
}
