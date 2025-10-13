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
      "saghen/blink.cmp"
    },
    config = function()
      local servers = {
        bashls = true,
        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            hint = { enable = true }
          }
        },
        ts_ls = {
          typescript = {
            codeActionsOnSave = {
              source = {
                organizeImports = true,
                fixAll = true,
                addMissingImports = true
              }
            },
            inlayHints = {
              includeInlayEnumMemberValueHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayParameterNameHints = 'all', -- 'none' | 'literals' | 'all';
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayVariableTypeHints = true,
            },
          },
        },
      }

      local capabilities = vim.lsp.protocol.make_client_capabilities()

      local init_options = {
        ts_ls = {
          hostInfo = "neovim",
          preferences = {
            quotePreference = 'single',
            includeCompletionsForModuleExports = true,
            includeCompletionsForImportStatements = true,
            importModuleSpecifierPreference = 'non-relative',
            importModuleSpecifierEnding = 'minimal',
          },
        }
      }

      require('mason').setup()
      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        handlers = {
          function(server_name)
            local lsp_capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
            require('lspconfig')[server_name].setup {
              capabilities = lsp_capabilities,

              on_attach = require("config.lsp-keymaps").register_lsp_keymaps,
              settings = servers[server_name],
              filetypes = (servers[server_name] or {}).filetypes,

              init_options = init_options[server_name] or {}
            }
          end,

          ['jdtls'] = function()
          end,
        }
      }
    end
  },
  {
    'saghen/blink.cmp',
    version = '1.*',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = 'default' },

      appearance = { nerd_font_variant = 'mono' },

      completion = {
        documentation = { auto_show = false },
        menu = { auto_show = false },
        ghost_text = { enabled = true },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      fuzzy = { implementation = "prefer_rust_with_warning" }
    },
    opts_extend = { "sources.default" }
  }
}
