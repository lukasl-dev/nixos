{ pkgs, ... }:

{
  home.packages = with pkgs; [
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
}
