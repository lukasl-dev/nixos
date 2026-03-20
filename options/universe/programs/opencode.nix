{
  inputs,
  pkgs,
  config,
  ...
}:

let
  inherit (config.universe) user;
  inherit (pkgs.stdenv.hostPlatform) system;

  inherit (pkgs.unstable) github-mcp-server;

  github-mcp-server-wrapped = pkgs.writeShellScriptBin "github-mcp-server" ''
    export GITHUB_PERSONAL_ACCESS_TOKEN="$(cat ${
      config.age.secrets."universe/opencode/github_pat".path
    })"
    exec ${github-mcp-server}/bin/github-mcp-server "$@"
  '';
  rime = inputs.rime.packages.${system}.default;

  opencode = inputs.opencode.packages.${system}.default.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace packages/script/src/index.ts \
        --replace-fail 'const expectedBunVersionRange = `^''${expectedBunVersion}`' 'const expectedBunVersionRange = ">=1.3.9"'
    '';
  });
in
{
  security.apparmor.policies.opencode = {
    state = "enforce";
    profile = ''
      abi <abi/4.0>,
      include <tunables/global>

      profile opencode "${opencode}/bin/opencode" {
        include <abstractions/base>

        allow all,

        audit deny "${pkgs.unstable.sops}/bin/sops" x,
        audit deny "${pkgs.sops}/bin/sops" x,
        audit deny "/etc/sops/age/**" rwklm,
        audit deny "/etc/sops/**" rwklm,

        audit deny "/etc/agenix/identity" rwklm,
        audit deny "/etc/agenix/**" rwklm,

        audit deny "/home/${user.name}/nixos/dns/creds.json" rwklm,

        audit deny "/run/secrets/" r,
        audit deny "/run/secrets/**" r,

        audit deny "/run/agenix/" r,
        audit deny "/run/agenix/**" r,
        audit deny "/run/agenix.d/" r,
        audit deny "/run/agenix.d/**" r,

        audit deny "/home/${user.name}/nixos/secrets/**" rwklm,
        audit deny "/home/${user.name}/nixos/sops/**" rwklm,
      }
    '';
  };

  age.secrets = {
    "universe/opencode/github_pat" = {
      rekeyFile = ../../../secrets/universe/opencode/github_pat.age;
      owner = user.name;
      path = "/home/${user.name}/.config/opencode/github_pat";
      symlink = false;
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

          ## Security Sandbox (AppArmor)

          - You are running inside a hardened AppArmor profile.
          - Access to secret material is intentionally denied, including:
            - `/home/${user.name}/nixos/secrets/**`
            - `/home/${user.name}/nixos/sops/**`
            - `/run/secrets/**`, `/run/agenix/**`, `/run/agenix.d/**`
            - `/etc/sops/**`, `/etc/agenix/**`
            - `/home/${user.name}/nixos/dns/creds.json`
          - If a command fails with `Permission denied` because it tries to read denied secret paths, do not relax security or request secrets.
          - Use a safe workaround instead:
            - create a temporary filtered copy of the repo excluding denied paths,
            - run the required read/update there (for example, `nix flake update --update-input <input>`),
            - copy back only the intended non-secret artifact (for example, `flake.lock`).
          - Report clearly when sandbox restrictions influenced the workflow.

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

          ## Review Discipline

          - After significant code changes, run the `critic` and `simplifier` agents before finishing.
          - Use the `critic` agent for bug risk, security risk, and maintainability review.
          - Use the `simplifier` agent to reduce unnecessary complexity while preserving behaviour.
        '';

        agents = {
          critic = # markdown
            ''
              # Critic Agent

              Review completed changes and produce concise, high-signal feedback.

              ## Focus Areas
              - Correctness and regression risk
              - Security and secret-handling risk
              - Nix/NixOS-specific pitfalls (module wiring, option semantics, evaluation hazards)
              - Test and validation gaps
              - Clarity and maintainability

              ## Workflow
              1. Inspect changed files and relevant surrounding code.
              2. Validate claims against the code (do not guess).
              3. Prioritize issues by severity and confidence.
              4. Suggest minimal, concrete fixes.

              ## Return Format
              - Verdict: `ship` or `needs changes`
              - Findings: ordered by severity, each with file path and rationale
              - Fix plan: shortest safe remediation steps
              - Validation: commands to confirm the fixes
            '';

          simplifier = # markdown
            ''
              # Simplifier Agent

              Review code for opportunities to reduce accidental complexity and shrink the implementation surface.

              ## Focus Areas
              - Remove indirection that does not improve clarity
              - Inline one-off helpers and wrappers used only once when readability improves
              - Inline single-use variables when the resulting line stays within 80 columns
              - Replace verbose patterns with idiomatic language features (for example, Zig blocks/expressions)
              - Eliminate dead code, redundant branches, and duplicated transformations
              - Prefer fewer moving parts over clever abstractions

              ## Constraints
              - Preserve behaviour, public interfaces, and security posture unless explicitly asked otherwise
              - Avoid style-only churn without measurable simplification
              - Do not inline when it harms readability or exceeds 80-column line width
              - Keep patches small and easy to verify

              ## Workflow
              1. Identify complexity hotspots in changed code.
              2. Propose simpler alternatives with concrete before/after reasoning.
              3. Rank proposals by impact and safety.
              4. Recommend the smallest safe simplification set first.

              ## Return Format
              - Complexity verdict: `already simple` or `can simplify`
              - Candidates: ordered by payoff, each with file path and simplification rationale
              - Inlining notes: single-use vars/helpers to inline (or why not, if >80 columns)
              - Proposed edits: minimal patch plan
              - Validation: commands/tests to confirm no behavioural drift
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
            messages_page_up = "ctrl+b";
            messages_page_down = "ctrl+f";
            messages_half_page_up = "none";
            messages_half_page_down = "none";
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
            # "opencode-openai-codex-auth@4.2.0"
            "opencode-gemini-auth@1.4.5"
            "opencode-wakatime@1.1.0"
            "opencode-anthropic-auth@0.0.9"
            "@franlol/opencode-md-table-formatter@0.0.3"
          ];
          provider = {
            # google = {
            #   models = {
            #     "gemini-3-flash-preview" = {
            #       name = "Gemini 3 Flash Preview";
            #       limit = {
            #         context = 1048576;
            #         output = 8192;
            #       };
            #       modalities = {
            #         input = [
            #           "text"
            #           "image"
            #         ];
            #         output = [ "text" ];
            #       };
            #     };
            #   };
            # };
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
