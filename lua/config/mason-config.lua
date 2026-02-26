return {
  servers = {
    lua_ls = {
      settings = {
        Lua = {
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
          hint = { enable = true }
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
      init_options = {
        hostInfo = "neovim",
        preferences = {
          quotePreference = 'single',
          includeCompletionsForModuleExports = true,
          includeCompletionsForImportStatements = true,
          importModuleSpecifierPreference = 'non-relative',
          importModuleSpecifierEnding = 'minimal',
        },
      },
    }
  }
}
