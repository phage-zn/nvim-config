local servers = {
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
  }
}

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
  },
  vuels = {}
}

local capabilities = vim.lsp.protocol.make_client_capabilities()

return {
  ensure_installed = vim.tbl_keys(servers),
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup {
        capabilities = capabilities,
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
