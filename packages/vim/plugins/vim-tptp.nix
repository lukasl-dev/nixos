{ pkgs, ... }:

let
  package = pkgs.vimUtils.buildVimPlugin {
    name = "vim-tptp";
    pname = "vim-tptp";
    src = pkgs.fetchFromGitHub {
      owner = "c-cube";
      repo = "vim-tptp";
      rev = "c8a010e8d1bbc7e0341346f6b8611d0f3849aaff";
      hash = "sha256-pIRIOpB0gkBHOxCmoqPjpsfZphDdZdDvKsfj91qbbGk=";
    };
  };
in
{
  vim.extraPlugins."vim-tptp" = {
    inherit package;
  };
}
