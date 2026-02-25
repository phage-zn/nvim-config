return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/lazydev.nvim",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "stevearc/conform.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local servers = {
        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            hint = { enable = true },
          },
        },
        pylsp = {
          pylsp = {
            plugins = {
              pyflakes = {
                enabled = false,
              },
              mccabe = {
                enabled = false,
              },
              flake8 = {
                enabled = false,
              },
              pycodestyle = {
                enabled = false,
              },
              ruff = {
                enabled = true,
                lineLength = 120,
              },
            },
            signature = {
              formatter = "ruff",
            },
          },
        },
        ts_ls = {
          typescript = {
            codeActionsOnSave = {
              source = {
                organizeImports = true,
                fixAll = true,
                addMissingImports = true,
              },
            },
            inlayHints = {
              includeInlayEnumMemberValueHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all';
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
        },
      }

      local init_options = {
        ts_ls = {
          hostInfo = "neovim",
          preferences = {
            quotePreference = "single",
            includeCompletionsForModuleExports = true,
            includeCompletionsForImportStatements = true,
            importModuleSpecifierPreference = "non-relative",
            importModuleSpecifierEnding = "minimal",
          },
        },
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local lsp_capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
      vim.lsp.config("*", {
        capabilities = lsp_capabilities,
      })

      for server_name, server_settings in pairs(servers) do
        vim.lsp.config(server_name, {
          settings = server_settings,
          init_options = init_options[server_name] or {},
        })
      end

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
      })
    end,
  },
  {
    "saghen/blink.cmp",
    version = "1.*",

    opts = {
      keymap = { preset = "default" },

      appearance = { nerd_font_variant = "mono" },

      completion = {
        documentation = { auto_show = false },
        menu = { auto_show = false },
        ghost_text = { enabled = true },
      },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
