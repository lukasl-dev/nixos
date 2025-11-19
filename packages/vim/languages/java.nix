# let
# Wrapper that chooses available IntelliJ CLI (ultimate > community),
# then runs the CLI formatter with all passed args (file path etc.).
# intellijFormat = pkgs.writeShellApplication {
#   name = "intellij-format";
#   text = ''
#     set -euo pipefail
#     IDE="${pkgs.jetbrains.idea-community-bin}/bin/idea-community"
#     if command -v idea-ultimate >/dev/null 2>&1; then
#       IDE="idea-ultimate"
#     elif command -v idea-community >/dev/null 2>&1; then
#       IDE="idea-community"
#     fi
#     exec "$IDE" format -allowDefaults "$@"
#   '';
# };
# in
{
  vim = {
    # extraPackages = [ intellijFormat ];

    languages.java.enable = true;

    # lsp.servers.jdtls.settings = {
    #   java = {
    #     project = {
    #       sourcePaths = [ "." ];
    #     };
    #   };
    # };

    # formatter.conform-nvim = {
    #   setupOpts = {
    #     formatters = {
    #       intellij_format = {
    #         command = "${intellijFormat}/bin/intellij-format";
    #         args = [ "$FILENAME" ];
    #         stdin = false;
    #         # Allow enough time for the JVM to start
    #         timeout_ms = 60000;
    #       };
    #     };
    #     formatters_by_ft.java = [ "intellij_format" ];
    #   };
    # };
  };
}
