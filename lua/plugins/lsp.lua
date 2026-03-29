return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },
  config = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local lsp_capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
    vim.lsp.config("*", {
      capabilities = lsp_capabilities,
    })

    require("mason").setup()
    local mason_config = {
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              hint = { enable = true },
            },
          },
        },
        ts_ls = {
          settings = {
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
                includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true,
              },
            },
          },
          init_options = {
            hostInfo = "neovim",
            preferences = {
              quotePreference = "single",
              includeCompletionsForModuleExports = true,
              includeCompletionsForImportStatements = true,
              importModuleSpecifierPreference = "non-relative",
              importModuleSpecifierEnding = "minimal",
            },
          },
        },
      },
    }
    require("mason-lspconfig").setup({
      ensure_installed = vim.tbl_keys(mason_config.servers),
    })

    for server_name, server_config in pairs(mason_config.servers) do
      vim.lsp.config(server_name, {
        settings = server_config.settings,
        init_options = server_config.init_options or {},
      })
    end
  end,
}
