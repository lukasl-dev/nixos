{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    cowsay
    hyperfine
    just
    jq
    file
    dysk
    cava
    tree
    man-pages

    python3
    uv
    python312Packages.grip
    python312Packages.pylatexenc
    (python312Packages.debugpy.overridePythonAttrs (_: {
      doCheck = false;
    }))
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
