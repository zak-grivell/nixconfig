{inputs, ...}: {
  flake-file.inputs = {
    nixvim.url = "github:nix-community/nixvim";
  };

  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    path-lsp = pkgs.callPackage ../../packages/path-lsp {};
    nixvim = inputs.self.darwinConfigurations.zakbook.config.home-manager.users.zakgrivell.programs.nixvim;
  in {
    packages.path-lsp = path-lsp;
    checks =
      {
        path-lsp =
          pkgs.runCommand "path-lsp-tests" {
            nativeBuildInputs = [pkgs.neovim pkgs.python3];
            PATH_LSP_PLUGIN = path-lsp;
            PATH_LSP_CONFORM = pkgs.vimPlugins.conform-nvim;
            PATH_LSP_TESTS = ../../packages/path-lsp/tests;
          } ''
            export HOME="$TMPDIR/home"
            mkdir -p "$HOME"
            nvim --headless -u NONE -l "$PATH_LSP_TESTS/test.lua"
            touch "$out"
          '';
      }
      // lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") {
        nvim-workflow =
          pkgs.runCommand "nvim-workflow-tests" {
            nativeBuildInputs = [
              nixvim.build.package
              pkgs.python3
            ];
            NIXVIM_INIT = nixvim.build.initFile;
            NIXVIM_RUNTIME = nixvim.build.extraFiles;
            PATH_LSP_TEST_SERVER = ../../packages/path-lsp/tests/server.py;
          } ''
            export HOME="$TMPDIR/home"
            mkdir -p "$HOME"
            nvim --headless --cmd "set rtp^=$NIXVIM_RUNTIME" -u "$NIXVIM_INIT" -c 'luafile ${../../nvim/tests.lua}'
            touch "$out"
          '';
      };
  };

  flake.homeModules.default = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      inputs.nixvim.homeModules.nixvim
    ];

    # Keep the editor's semantic palette: Stylix otherwise applies mini.base16
    # after Catppuccin and replaces its syntax and UI highlights.
    stylix.targets.nixvim.enable = false;

    programs.nixvim = {
      enable = true;

      extraPlugins = [
        (pkgs.callPackage ../../packages/path-lsp {
          helixOverrides = config.programs.helix.languages;
        })
      ];
      extraPackages = [pkgs.ripgrep pkgs.fd];
      extraConfigLua = ''
        require("path-lsp").setup()
        require("editor-workflow").setup()
      '';
      extraFiles."lua/editor-workflow.lua".source = ../../nvim/workflow.lua;
      globals.mapleader = " ";

      colorschemes.catppuccin = {
        enable = true;
        settings = {
          flavour = "frappe";
          transparent_background = false;
          no_italic = true;
          no_bold = true;
          no_underline = true;
          custom_highlights.__raw = ''
            function(c)
              return {
                Normal = { fg = c.text, bg = c.base },
                NormalNC = { fg = c.text, bg = c.base },
                SignColumn = { bg = c.base },
                LineNr = { fg = c.surface2, bg = c.base },
                CursorLineNr = { fg = c.lavender, bg = c.base },
                EndOfBuffer = { fg = c.base, bg = c.base },
                WinSeparator = { fg = c.surface1, bg = c.base },
              }
            end
          '';
        };
      };

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
        wrap = true;
        linebreak = true;
        breakindent = true;
        fixendofline = false;
        hidden = true;
        showtabline = 2;
        showmode = false;
        laststatus = 3;
        fillchars = {eob = " ";};
      };

      plugins = {
        # Syntax / structural editing
        treesitter = {
          enable = true;
          highlight.enable = true;
          indent.enable = true;
        };
        treesitter-textobjects.enable = true;
        multicursor.enable = true;
        bufferline = {
          enable = true;
          settings.options = {
            diagnostics = "nvim_lsp";
            always_show_bufferline = true;
            show_buffer_icons = false;
            show_buffer_close_icons = false;
            show_close_icon = false;
            separator_style = "thin";
            indicator.style = "none";
          };
        };
        lsp-signature = {
          enable = true;
          settings = {
            hint_enable = false;
            handler_opts.border = "rounded";
            doc_lines = 2;
          };
        };

        # path-lsp starts servers from Helix defaults when found on PATH.
        cmp-nvim-lsp.enable = true;

        cmp = {
          enable = true;
          autoEnableSources = true;
          settings = {
            snippet.expand.__raw = "function(args) vim.snippet.expand(args.body) end";
            sources = [
              {name = "nvim_lsp";}
              {name = "path";}
              {name = "buffer";}
            ];
            mapping = {
              "<Tab>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.confirm({ select = true }) else fallback() end end, {'i'})";
              "<C-n>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_next_item() else fallback() end end, {'i'})";
              "<C-p>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_prev_item() else fallback() end end, {'i'})";
              "<C-y>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.confirm({ select = true }) else fallback() end end, {'i'})";
              "<C-Space>" = "cmp.mapping.complete()";
            };
          };
        };

        telescope = {
          enable = true;
          settings.defaults = {
            file_ignore_patterns = ["%.direnv/" "%.git/"];
            vimgrep_arguments = ["rg" "--color=never" "--no-heading" "--with-filename" "--line-number" "--column" "--smart-case" "--glob" "!.direnv/**"];
          };
        };

        oil.enable = true;

        flash = {
          enable = true;
          settings.modes.char.enabled = false;
        };

        # Better diagnostics list
        trouble.enable = true;

        # Git gutter
        gitsigns.enable = true;

        # Formatting
        conform-nvim = {
          enable = true;
          # path-lsp supplies project-aware formatters and format-on-save.
        };

        # Quality-of-life editing
        mini = {
          enable = true;
          modules = {
            surround.mappings = {
              add = "ys";
              delete = "ds";
              replace = "cs";
              find = "";
              find_left = "";
              highlight = "";
              update_n_lines = "";
            };
            pairs = {};
          };
        };

        which-key = {
          enable = true;
          settings.delay = 300;
        };

        # Minimal statusline
        lualine = {
          enable = true;
          settings = {
            options = {
              theme = "catppuccin-frappe";
              icons_enabled = false;
              globalstatus = true;
              component_separators = "";
              section_separators = "";
            };
            sections = {
              lualine_a = ["mode"];
              lualine_b = [];
              lualine_c = [
                {
                  "__unkeyed-1" = "filename";
                  path = 1;
                }
                "diagnostics"
              ];
              lualine_x = ["filetype"];
              lualine_y = [];
              lualine_z = ["location"];
            };
          };
        };
      };
    };
  };
}
