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
          - Delegate to preserve main context.

          ## Exploration (CRITICAL)

          - **ALWAYS** use `explore` agent for codebase navigation:
            - "Where is X?"
            - "Find files matching Y"
            - "How does Z work?"
            - Any search that might need multiple glob/grep/read cycles
          - **NEVER** glob/grep/read directly in main context for exploration tasks.
          - Use `general` agent when exploration needs multi-step synthesis.

          ## Tooling

          - Prefer `rg` / `rg --files` for search.
          - Use `ast-grep` for structural search.
          - If a tool is missing, use `nix run` (e.g., `nix run nixpkgs#ripgrep -- rg ...`).
          - For multi-tool sessions, use `nix shell` to enter a temporary environment.

          ## Scratchpad (Knowledge Cache)

          - `.scratchpad/*.md` persists across sessions.
          - Domain agents (nix, zig) read/write scratchpad directly.
          - Before deep exploration: check scratchpad.
          - After expensive research: write to scratchpad.

          ## Domain Agents

          - `nix`: ALL Nix/NixOS work.
          - `obsidian`: Notes/knowledge base.
          - `zig`: Zig development.
        '';

        agents = {
          explore = # markdown
            ''
              ---
              description: Fast codebase exploration (read-only)
              mode: subagent
              tools:
                write: false
                edit: false
                bash: true
              ---

              # Explore Agent

              You are a read-only exploration agent. Your job is to locate relevant files, symbols, and patterns quickly.

              ## Workflow
              1. Use glob/grep/read to find candidates
              2. Verify by reading files
              3. Summarize findings concisely

              ## Tooling
              - Prefer `rg` and `rg --files` for fast search
              - Use `ast-grep` for structural search
              - If missing, use `nix run` (e.g., `nix run nixpkgs#ripgrep -- rg ...`)
              - Use `nix shell` to enter a temporary tooling environment
              - Keep commands read-only; do not modify files

              ## Return Format
              - Answer to the user's question (1-3 sentences)
              - Relevant files (list with brief reasons)
              - Suggested next step (optional)
            '';

          nix = # markdown
            ''
              # Nix Agent

              Specialized agent for Nix/NixOS work. Handle ALL Nix-related tasks autonomously.

              ## Scratchpad
              - Read `.scratchpad/nix-*.md` before deep exploration
              - Write findings to `.scratchpad/nix-<topic>.md` after learning non-obvious patterns
              - Format: `# Title`, `## Summary`, `## Details`, `## References`

              ## Workflow
              1. Check scratchpad for cached knowledge
              2. Use `rime` MCP tools (manix, nixhub, wiki)
              3. Make changes
              4. Validate: `nix flake check` or `nix-instantiate --parse`
              5. Format: `nixfmt`
              6. Cache new knowledge to scratchpad

              ## Return Format
              - What was changed
              - Commands to run (e.g., `nixos-rebuild switch`)
            '';

          obsidian = # markdown
            ''
              # Obsidian Agent

              Manage the personal knowledge base at `~/notes/content/Knowledge`.

              ## Style (MUST match exactly)

              - **Frontmatter**: YAML with `aliases:` list
              - **Tags**: After frontmatter (`#search`, `#linux`)
              - **Callouts**: `[!def]`, `[!theorem]`, `[!proof]`, `[!axiom]`, `[!intuition]`, `[!idea]`, `[!obs]`, `[!abstract]`
              - **Links**: ALWAYS `[[Knowledge/Path|lowercase alias]]`. Never bare links.
              - **Math**: LaTeX (`$`, `$$`)
              - **Tone**: Academic, concise, British spelling

              ## Return Format
              - Note path created/modified
              - Links added
            '';

          zig = # markdown
            ''
              # Zig Agent

              Handle Zig development tasks autonomously.

              ## Scratchpad
              - Read `.scratchpad/zig-*.md` before exploring stdlib
              - Write findings to `.scratchpad/zig-<topic>.md` after learning non-obvious patterns
              - Format: `# Title`, `## Summary`, `## Details`, `## References`

              ## Access
              Zig stdlib: `zig env | jq -r .std_dir`

              ## Workflow
              1. Check scratchpad for cached knowledge
              2. Make changes
              3. Format: `zig fmt <file>`
              4. Test: `systemd-run --user --scope zig build test`
              5. Cache new stdlib/pattern knowledge to scratchpad

              ## Return Format
              - Changes made
              - Test results (pass/fail)
            '';
        };

        settings = {
          plugin = [
            "opencode-openai-codex-auth@4.2.0"
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
                "gpt-5.2-none" = {
                  name = "GPT 5.2 None (OAuth)";
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
                    reasoningEffort = "none";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.2-low" = {
                  name = "GPT 5.2 Low (OAuth)";
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
                    reasoningEffort = "low";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.2-medium" = {
                  name = "GPT 5.2 Medium (OAuth)";
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
                    reasoningEffort = "medium";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
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
                "gpt-5.2-xhigh" = {
                  name = "GPT 5.2 Extra High (OAuth)";
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
                    reasoningEffort = "xhigh";
                    reasoningSummary = "detailed";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.2-codex-low" = {
                  name = "GPT 5.2 Codex Low (OAuth)";
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
                    reasoningEffort = "low";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.2-codex-medium" = {
                  name = "GPT 5.2 Codex Medium (OAuth)";
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
                    reasoningEffort = "medium";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.2-codex-high" = {
                  name = "GPT 5.2 Codex High (OAuth)";
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
                "gpt-5.2-codex-xhigh" = {
                  name = "GPT 5.2 Codex Extra High (OAuth)";
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
                    reasoningEffort = "xhigh";
                    reasoningSummary = "detailed";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.1-codex-max-low" = {
                  name = "GPT 5.1 Codex Max Low (OAuth)";
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
                    reasoningEffort = "low";
                    reasoningSummary = "detailed";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.1-codex-max-medium" = {
                  name = "GPT 5.1 Codex Max Medium (OAuth)";
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
                    reasoningEffort = "medium";
                    reasoningSummary = "detailed";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.1-codex-max-high" = {
                  name = "GPT 5.1 Codex Max High (OAuth)";
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
                "gpt-5.1-codex-max-xhigh" = {
                  name = "GPT 5.1 Codex Max Extra High (OAuth)";
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
                    reasoningEffort = "xhigh";
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
                  modalities = {
                    input = [
                      "text"
                      "image"
                    ];
                    output = [ "text" ];
                  };
                  options = {
                    reasoningEffort = "low";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.1-codex-medium" = {
                  name = "GPT 5.1 Codex Medium (OAuth)";
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
                    reasoningEffort = "medium";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.1-codex-high" = {
                  name = "GPT 5.1 Codex High (OAuth)";
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
                "gpt-5.1-codex-mini-medium" = {
                  name = "GPT 5.1 Codex Mini Medium (OAuth)";
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
                    reasoningEffort = "medium";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.1-codex-mini-high" = {
                  name = "GPT 5.1 Codex Mini High (OAuth)";
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
                "gpt-5.1-none" = {
                  name = "GPT 5.1 None (OAuth)";
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
                    reasoningEffort = "none";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.1-low" = {
                  name = "GPT 5.1 Low (OAuth)";
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
                    reasoningEffort = "low";
                    reasoningSummary = "auto";
                    textVerbosity = "low";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.1-medium" = {
                  name = "GPT 5.1 Medium (OAuth)";
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
                    reasoningEffort = "medium";
                    reasoningSummary = "auto";
                    textVerbosity = "medium";
                    include = [ "reasoning.encrypted_content" ];
                    store = false;
                  };
                };
                "gpt-5.1-high" = {
                  name = "GPT 5.1 High (OAuth)";
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
                    textVerbosity = "high";
                    include = [ "reasoning.encrypted_content" ];
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
