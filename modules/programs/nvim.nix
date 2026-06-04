{inputs, ...}: {
  flake-file.inputs = {
    nixvim.url = "github:nix-community/nixvim";
  };

  flake.homeModules.disabled = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      inputs.nixvim.homeModules.nixvim
    ];

    programs.nixvim = {
      enable = true;

      colorschemes.catppuccin.enable = true;
      # plugins.lualine.enable = true;
      # plugins.lspconfig.enable = true;plugins.lspconfig.autoLoad = true;

      # Helix-like sane defaults
      opts = {
        number = true;
        relativenumber = true;
        mouse = "a";
        ignorecase = true;
        smartcase = true;
        splitright = true;
        splitbelow = true;
        termguicolors = true;
        updatetime = 250;
        signcolumn = "yes";
      };

      plugins = {
        # Syntax / structural editing
        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
        };

        # LSP like Helix has built in
        lsp = {
          enable = true;
          servers = {
            nil_ls.enable = true;
            rust_analyzer.enable = true;
            clangd.enable = true;
            pyright.enable = true;
            ts_ls.enable = true;
          };
        };

        # Completion. Could use blink-cmp instead if you prefer newer/faster.
        cmp = {
          enable = true;
          autoEnableSources = true;
          settings = {
            sources = [
              {name = "nvim_lsp";}
              {name = "path";}
              {name = "buffer";}
            ];
            mapping = {
              "<Tab>" = "cmp.mapping.select_next_item()";
              "<S-Tab>" = "cmp.mapping.select_prev_item()";
              "<CR>" = "cmp.mapping.confirm({ select = true })";
            };
          };
        };

        # Helix-like fuzzy picker
        telescope = {
          enable = true;
          extensions.file-browser.enable = true;
        };

        # File browser: pick one
        oil.enable = true; # edit directories like buffers
        # yazi.enable = true; # floating terminal file manager

        # Helix-like jump/search motions
        flash.enable = true;

        # Better diagnostics list
        trouble.enable = true;

        # Git gutter
        gitsigns.enable = true;

        # Formatting
        conform-nvim = {
          enable = true;
          settings = {
            format_on_save = {
              timeout_ms = 500;
              lsp_fallback = true;
            };
          };
        };

        # Quality-of-life editing
        nvim-autopairs.enable = true;
        comment.enable = true;
        mini = {
          enable = true;
          modules = {
            surround = {};
            pairs = {};
            ai = {}; # textobjects, like around/inside
          };
        };

        # Key hint popup, useful when building Helix-like leader maps
        which-key.enable = true;

        # Minimal statusline
        lualine = {
          enable = true;
          settings.options = {
            globalstatus = true;
            component_separators = "";
            section_separators = "";
          };
        };
      };

      keymaps = [
        # Telescope / picker
        {
          mode = "n";
          key = "<space>f";
          action = "<cmd>Telescope find_files<CR>";
          options.desc = "Find files";
        }
        {
          mode = "n";
          key = "<space>g";
          action = "<cmd>Telescope live_grep<CR>";
          options.desc = "Live grep";
        }
        {
          mode = "n";
          key = "<space>b";
          action = "<cmd>Telescope buffers<CR>";
          options.desc = "Buffers";
        }

        # File browser
        {
          mode = "n";
          key = "<space>e";
          action = "<cmd>Oil<CR>";
          options.desc = "Open file explorer";
        }

        # LSP, roughly Helix-style under space
        {
          mode = "n";
          key = "<space>ca";
          action = "<cmd>lua vim.lsp.buf.code_action()<CR>";
          options.desc = "Code action";
        }
        {
          mode = "n";
          key = "<space>rn";
          action = "<cmd>lua vim.lsp.buf.rename()<CR>";
          options.desc = "Rename";
        }
        {
          mode = "n";
          key = "gd";
          action = "<cmd>lua vim.lsp.buf.definition()<CR>";
          options.desc = "Goto definition";
        }
        {
          mode = "n";
          key = "gr";
          action = "<cmd>lua vim.lsp.buf.references()<CR>";
          options.desc = "References";
        }
        {
          mode = "n";
          key = "K";
          action = "<cmd>lua vim.lsp.buf.hover()<CR>";
          options.desc = "Hover";
        } # Diagnostics
        {
          mode = "n";
          key = "<space>d";
          action = "<cmd>Trouble diagnostics toggle<CR>";
          options.desc = "Diagnostics";
        }
      ];
    };
  };
}
