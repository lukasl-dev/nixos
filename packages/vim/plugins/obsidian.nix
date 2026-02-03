{
  vim = {
    notes.obsidian = {
      enable = true;

      setupOpts = {
        workspaces = [
          {
            name = "notes";
            path = "~/notes/content";
          }
        ];

        completion.blink = false;

        wiki_link_func = {
          _type = "lua-inline";
          expr = # lua
            ''
              function(opts)
                local path = opts.path
                path = path:gsub("%.md$", "")
                if opts.label and opts.label ~= "" and opts.label ~= path then
                  return string.format("[[%s|%s]]", path, opts.label)
                else
                  return string.format("[[%s]]", path)
                end
              end
            '';
        };

        daily_notes = {
          folder = "Personal/Daily";
          date_format = "%Y-%m-%d";
          template = "Daily (Template).md";
        };

        templates = {
          subdir = "Templates";
          date_format = "%Y-%m-%d";
          time_format = "%H:%M";
        };

        open_notes_in = "current";

        disable_frontmatter = true;

        mappings = {
          gf = {
            action = {
              _type = "lua-inline";
              expr = ''
                function()
                  return require("obsidian").util.gf_passthrough()
                end
              '';
            };
            opts = {
              noremap = false;
              expr = true;
              buffer = true;
            };
          };
        };

        # use render-markdown-nvim instead
        ui = {
          enable = false;
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>ns";
        action = ":ObsidianSearch<CR>";
        silent = true;
        desc = "Search notes";
      }
      {
        mode = "n";
        key = "<leader>nd";
        action = ":ObsidianToday<CR>";
        silent = true;
        desc = "Daily note";
      }
      {
        mode = "n";
        key = "<leader>nt";
        action = ":ObsidianTemplate<CR>";
        silent = true;
        desc = "Insert template";
      }
      {
        mode = "n";
        key = "<leader>nb";
        action = ":ObsidianBacklinks<CR>";
        silent = true;
        desc = "Backlinks";
      }
      {
        mode = "n";
        key = "<leader>nl";
        action = ":ObsidianLinks<CR>";
        silent = true;
        desc = "Links";
      }
    ];
  };
}
