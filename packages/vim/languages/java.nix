{ pkgs, ... }:

let
  jdtls-lombok = pkgs.writeShellScriptBin "jdtls" ''
    exec ${pkgs.jdt-language-server}/bin/jdtls --jvm-arg=-javaagent:${pkgs.lombok}/share/java/lombok.jar "$@"
  '';
in
{
  vim = {
    extraPackages = with pkgs; [ google-java-format ];

    languages.java = {
      enable = true;
      lsp.package = jdtls-lombok;
    };

    formatter.conform-nvim.setupOpts.formatters_by_ft.java = [ "google-java-format" ];
  };
}
