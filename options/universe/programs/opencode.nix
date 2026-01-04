{
  inputs,
  pkgs,
  pkgs-unstable,
  config,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) system;

  inherit (config) sops;

  inherit (pkgs-unstable) github-mcp-server;

  github-mcp-server-wrapped = pkgs.writeShellScriptBin "github-mcp-server" ''
    source ${config.sops.templates."universe/opencode/env".path}
    exec ${github-mcp-server}/bin/github-mcp-server "$@"
  '';

  opencode =
    let
      pkg = inputs.opencode.packages.${system}.default;
    in
    pkgs.symlinkJoin {
      inherit (pkg) name;
      paths = [ pkg ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        rm $out/bin/opencode
        makeWrapper ${pkgs.firejail}/bin/firejail $out/bin/opencode \
          --add-flags "--noprofile" \
          --add-flags "--blacklist=sops" \
          --add-flags "--blacklist=${pkgs-unstable.sops}/bin/sops" \
          --add-flags "--blacklist=${pkgs.sops}/bin/sops" \
          --add-flags "--blacklist=${sops.age.keyFile}" \
          --add-flags "--" \
          --add-flags "${pkg}/bin/opencode"
        sed -i 's|${pkgs.firejail}/bin/firejail|/run/wrappers/bin/firejail|' $out/bin/opencode
      '';
    };

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

          - **NEVER** perform commits.

          ## Exploration (CRITICAL)

          - **ALWAYS** explore the codebase:
            - "Where is X?"
            - "Find files matching Y"
            - "How does Z work?"
            - Any search that might need multiple glob/grep/read cycles

          ## Tooling

          - Prefer `rg` / `rg --files` for search.
          - Use `ast-grep` for structural search.
          - If a tool is missing, use `nix run` (e.g., `nix run nixpkgs#ripgrep -- rg ...`).
          - For multi-tool sessions, use `nix shell` to enter a temporary environment.

          ## Scratchpad (Knowledge Cache)

          - `.scratchpad/*.md` persists across sessions.
          - Use the format `YYYY-MM-DD-topic.md` for scratchpad files (e.g., `2025-11-03-zig-stdlib_changes.md`).
          - Domain agents (nix, zig) read/write scratchpad directly.
          - Before deep exploration: check scratchpad.
          - After expensive research: write to scratchpad.

          ## Domain Agents

          - `nix`: ALL Nix/NixOS work.
          - `obsidian`: Notes/knowledge base.
          - `zig`: Zig development.
        '';

        agents = {
          nix = # markdown
            ''
              # Nix Agent

              Specialized agent for Nix/NixOS work. Handle ALL Nix-related tasks autonomously.

              ## Scratchpad
              - Read `.scratchpad/*-nix-*.md` before deep exploration
              - Write findings to `.scratchpad/YYYY-MM-DD-nix-<topic>.md` after learning non-obvious patterns
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
              - **CRITICAL**: Read `.scratchpad/*-zig-*.md` before exploring stdlib or implementing features.
              - **ALWAYS** write findings to `.scratchpad/YYYY-MM-DD-zig-<topic>.md` after learning non-obvious patterns or solving complex issues.
              - Use the scratchpad to avoid redundant research and maintain continuity.
              - Format: `# Title`, `## Summary`, `## Details`, `## References`

              ## Access
              Zig stdlib: `zig env | jq -r .std_dir`

              ## Workflow
              1. **Consult Scratchpad**: Check existing notes for context or similar implementations.
              2. Make changes
              3. Format: `zig fmt <file>`
              4. Test: `systemd-run --user --scope zig build test`
              5. **Update Scratchpad**: Cache new stdlib/pattern knowledge to scratchpad.

              ## Return Format
              - Changes made
              - Test results (pass/fail)
            '';
        };

        settings = {
          keybinds = {
            leader = "ctrl+x";
            app_exit = "ctrl+c,ctrl+d,<leader>q";
            editor_open = "<leader>e";
            theme_list = "<leader>t";
            sidebar_toggle = "<leader>b";
            username_toggle = "none";
            status_view = "<leader>s";
            session_export = "<leader>x";
            session_new = "<leader>n";
            session_list = "<leader>l";
            session_timeline = "none";
            session_share = "none";
            session_unshare = "none";
            session_interrupt = "escape";
            session_compact = "<leader>c";
            session_child_cycle = "<leader>right";
            session_child_cycle_reverse = "<leader>left";
            session_parent = "<leader>up";
            messages_page_up = "pageup";
            messages_page_down = "pagedown";
            messages_half_page_up = "ctrl+alt+u,ctrl+b";
            messages_half_page_down = "ctrl+alt+d,ctrl+f";
            messages_first = "<leader>g,home";
            messages_last = "<leader>shift+g,end";
            messages_next = "none";
            messages_previous = "none";
            messages_copy = "<leader>y";
            messages_undo = "<leader>u";
            messages_redo = "<leader>r";
            messages_last_user = "none";
            messages_toggle_conceal = "<leader>h";
            model_list = "<leader>m";
            model_cycle_recent = "f2";
            model_cycle_recent_reverse = "shift+f2";
            variant_cycle = "ctrl+t";
            command_list = "ctrl+p";
            agent_list = "<leader>a";
            agent_cycle = "tab";
            agent_cycle_reverse = "shift+tab";
            input_clear = "ctrl+c";
            input_paste = "ctrl+v";
            input_submit = "return";
            input_newline = "shift+return,ctrl+return,alt+return,ctrl+j";
            input_move_left = "left";
            input_move_right = "right";
            input_move_up = "up";
            input_move_down = "down";
            input_select_left = "shift+left";
            input_select_right = "shift+right";
            input_select_up = "shift+up";
            input_select_down = "shift+down";
            input_line_home = "ctrl+a";
            input_line_end = "ctrl+e";
            input_select_line_home = "ctrl+shift+a";
            input_select_line_end = "ctrl+shift+e";
            input_visual_line_home = "alt+a";
            input_visual_line_end = "alt+e";
            input_select_visual_line_home = "alt+shift+a";
            input_select_visual_line_end = "alt+shift+e";
            input_buffer_home = "home";
            input_buffer_end = "end";
            input_select_buffer_home = "shift+home";
            input_select_buffer_end = "shift+end";
            input_delete_line = "ctrl+shift+d";
            input_delete_to_line_end = "ctrl+k";
            input_delete_to_line_start = "ctrl+u";
            input_backspace = "backspace,shift+backspace";
            input_delete = "ctrl+d,delete,shift+delete";
            input_undo = "ctrl+-,super+z";
            input_redo = "ctrl+.,super+shift+z";
            input_word_forward = "alt+f,alt+right,ctrl+right";
            input_word_backward = "alt+b,alt+left,ctrl+left";
            input_select_word_forward = "alt+shift+f,alt+shift+right";
            input_select_word_backward = "alt+shift+b,alt+shift+left";
            input_delete_word_forward = "alt+d,alt+delete,ctrl+delete";
            input_delete_word_backward = "ctrl+w,ctrl+backspace,alt+backspace";
            history_previous = "up";
            history_next = "down";
            terminal_suspend = "ctrl+z";
          };

          plugin = [
            "opencode-openai-codex-auth@4.2.0"
            "opencode-gemini-auth@1.3.6"
            "opencode-wakatime@1.1.0"
          ];
          provider = {
            google = {
              models = {
                "gemini-3-flash-preview" = {
                  name = "Gemini 3 Flash Preview";
                  limit = {
                    context = 1048576;
                    output = 8192;
                  };
                  modalities = {
                    input = [
                      "text"
                      "image"
                    ];
                    output = [ "text" ];
                  };
                };
              };
            };
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
