{
  inputs,
  pkgs,
  pkgs-unstable,
  config,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;

  inherit (pkgs-unstable) github-mcp-server;

  github-mcp-server-wrapped = pkgs.writeShellScriptBin "github-mcp-server" ''
    source ${config.sops.templates."universe/opencode/env".path}
    exec ${github-mcp-server}/bin/github-mcp-server "$@"
  '';

  opencode = inputs.opencode.packages.${system}.default;
  # opencode-wrapped = pkgs.writeShellScriptBin "opencode" ''
  #   exec ${pkgs.firejail}/bin/firejail --blacklist=$(which sops) ${opencode}/bin/opencode "$@"
  # '';

  rime = inputs.rime.packages.${system}.default;
in
{
  sops = {
    secrets."universe/opencode/github_pat" = { };
    templates."universe/opencode/env" = {
      owner = config.universe.user.name;
      content = ''
        export GITHUB_PERSONAL_ACCESS_TOKEN="${config.sops.placeholder."universe/opencode/github_pat"}"
      '';
    };
  };

  universe.hm = [
    {
      programs.opencode = {
        enable = true;
        package = opencode;

        rules = ''
          # Rules

          - Never commit.
          - ALWAYS use the Task tool with the appropriate subagent for complex tasks or domain-specific work.
          - Use the 'nix' agent for any Nix/NixOS related tasks.
          - Use the 'obsidian' agent for any notes/knowledge base related tasks.
          - Use the 'zig' agent for Zig programming.
        '';

        agents = {
          nix = # markdown
            ''
              # Nix Expert

              You are a Nix and NixOS expert. You understand flakes, modules, and the Nix language deeply.

              ## Guidelines

              - Format a changed file using `nixfmt`.
              - When modifying configuration, check for syntax errors using `nix instantiate --parse`.
              - Use the `rime` MCP tools for Nix-specific operations.
            '';

          obsidian = # markdown
            ''
              # Obsidian Expert

              You are an expert at creating and maintaining Obsidian notes in the user's personal knowledge base (`~/notes/content/Knowledge`).
              Your goal is to match the existing style EXACTLY.

              ## Style Guidelines

              1. **Frontmatter**:
                 Always start with YAML frontmatter containing aliases.
                 ```yaml
                 ---
                 aliases:
                   - Alias 1
                 ---
                 ```

              2. **Tags**:
                 Immediately follow frontmatter with relevant tags (e.g., `#search`, `#linux`).

              3. **Callouts**:
                 Use specific callout types defined in `~/notes/content/.obsidian/snippets/customisations.css`:
                 - `[!def]` for Definitions
                 - `[!theorem]` for Theorems
                 - `[!proof]` for Proofs
                 - `[!axiom]`, `[!intuition]`, `[!idea]`, `[!obs]`, `[!abstract]` as needed.

                 Example:
                 ```markdown
                 ## Definition
                 > [!def] Title
                 > The definition text...
                 ```

              4. **Linking**:
                 - **MANDATORY**: Always use absolute paths starting with `Knowledge/`.
                 - **MANDATORY**: ALWAYS provide an alias. `[[Knowledge/Note]]` is FORBIDDEN.
                 - **MANDATORY**: Aliases must be lowercase, unless referring to a proper noun (e.g., Turing, Gaussian).
                 - **CONTEXT-AWARE**: Do not link based solely on name matching. Ensure the linked note is relevant to the specific context (e.g., link "Normalisation" to the specific mathematical subdiscipline relevant to the text, not just a generic note).
                 - Example: `[[Knowledge/A-Star Search|A* search]]` (correct), `[[Knowledge/A-Star Search]]` (incorrect).

              5. **Math**:
                 - Use LaTeX for all mathematical expressions (`$`, `$$`).

              6. **Tone & Structure**:
                 - Academic, concise, and structured.
                 - Use headers (`##`, `###`) to organize content logically.

              7. **Markdown Linting**:
                 - Preserve existing markdown linting recommendations.
                 - Ensure valid markdown syntax.
            '';

          zig = # markdown
            ''
              # Zig Expert

              You're the Zig expert who is always up2date with the newest Zig
              standard library changes.

              You can access the Zig standard library directory at:
              ```bash
              zig env | awk -F'"' '/std_dir/ { print $2; exit }'
              ```

              ## Guidelines

              - Format a changed file using `zig fmt [file]`.
              - Run always all tests using `zig build test`. Don't run tests individually.
              - To prevent system crashes, run builds and tests using `systemd-run`, if available.
            '';
        };

        settings = {
          plugin = [
            "opencode-openai-codex-auth@4.1.0"
            "opencode-gemini-auth@1.2.0"
          ];
          provider = {
            openai = {
              options = {
                reasoningEffort = "medium";
                reasoningSummary = "auto";
                textVerbosity = "medium";
                include = [
                  "reasoning.encrypted_content"
                ];
                store = false;
              };
              models = {
                "gpt-5.2-high" = {
                  name = "GPT 5.2 High (OAuth)";
                  limit = {
                    context = 272000;
                    output = 128000;
                  };
                  modalities = {
                    input = [
                      "text"
                      "image"
                    ];
                    output = [ "text" ];
                  };
                  options = {
                    reasoningEffort = "high";
                    reasoningSummary = "detailed";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.1-codex-low" = {
                  name = "GPT 5.1 Codex Low (OAuth)";
                  limit = {
                    context = 272000;
                    output = 128000;
                  };
                  options = {
                    reasoningEffort = "low";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [
                      "reasoning.encrypted_content"
                    ];
                    store = false;
                  };
                };
                "gpt-5.1-codex-medium" = {
                  name = "GPT 5.1 Codex Medium (OAuth)";
                  limit = {
                    context = 272000;
                    output = 128000;
                  };
                  options = {
                    reasoningEffort = "medium";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [
                      "reasoning.encrypted_content"
                    ];
                    store = false;
                  };
                };
                "gpt-5.1-codex-high" = {
                  name = "GPT 5.1 Codex High (OAuth)";
                  limit = {
                    context = 272000;
                    output = 128000;
                  };
                  options = {
                    reasoningEffort = "high";
                    reasoningSummary = "detailed";
                    textVerbosity = "medium";
                    include = [
                      "reasoning.encrypted_content"
                    ];
                    store = false;
                  };
                };
                "gpt-5.1-codex-mini-medium" = {
                  name = "GPT 5.1 Codex Mini Medium (OAuth)";
                  limit = {
                    context = 272000;
                    output = 128000;
                  };
                  options = {
                    reasoningEffort = "medium";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [
                      "reasoning.encrypted_content"
                    ];
                    store = false;
                  };
                };
                "gpt-5.1-codex-mini-high" = {
                  name = "GPT 5.1 Codex Mini High (OAuth)";
                  limit = {
                    context = 272000;
                    output = 128000;
                  };
                  options = {
                    reasoningEffort = "high";
                    reasoningSummary = "detailed";
                    textVerbosity = "medium";
                    include = [
                      "reasoning.encrypted_content"
                    ];
                    store = false;
                  };
                };
                "gpt-5.1-low" = {
                  name = "GPT 5.1 Low (OAuth)";
                  limit = {
                    context = 272000;
                    output = 128000;
                  };
                  options = {
                    reasoningEffort = "low";
                    reasoningSummary = "auto";
                    textVerbosity = "low";
                    include = [
                      "reasoning.encrypted_content"
                    ];
                    store = false;
                  };
                };
                "gpt-5.1-medium" = {
                  name = "GPT 5.1 Medium (OAuth)";
                  limit = {
                    context = 272000;
                    output = 128000;
                  };
                  options = {
                    reasoningEffort = "medium";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [
                      "reasoning.encrypted_content"
                    ];
                    store = false;
                  };
                };
                "gpt-5.1-high" = {
                  name = "GPT 5.1 High (OAuth)";
                  limit = {
                    context = 272000;
                    output = 128000;
                  };
                  options = {
                    reasoningEffort = "high";
                    reasoningSummary = "detailed";
                    textVerbosity = "high";
                    include = [
                      "reasoning.encrypted_content"
                    ];
                    store = false;
                  };
                };
              };
            };
          };
          mcp = {
            rime = {
              type = "local";
              command = [
                "${rime}/bin/rime"
                "stdio"
              ];
              enabled = true;
            };
            github = {
              type = "local";
              command = [
                "${github-mcp-server-wrapped}/bin/github-mcp-server"
                "stdio"
              ];
              enabled = true;
            };
          };
        };
      };
    }
  ];
}
