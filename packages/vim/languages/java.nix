{ pkgs, lib, ... }:

let
  jdtls-lombok = pkgs.writeShellScriptBin "jdtls" ''
    exec ${pkgs.jdt-language-server}/bin/jdtls --jvm-arg=-javaagent:${pkgs.lombok}/share/java/lombok.jar "$@"
  '';
in
{
  vim = {
    extraPackages = with pkgs; [ google-java-format ];

    languages.java.enable = true;

    lsp.servers.jdtls.cmd = lib.mkForce (
      lib.generators.mkLuaInline # lua
        ''
          {
            "${lib.getExe jdtls-lombok}",
            "-data",
            vim.fn.stdpath("cache") .. "/jdtls/workspace"
          }
        ''
    );

    formatter.conform-nvim.setupOpts.formatters_by_ft.java = [ "google-java-format" ];
  };
}
