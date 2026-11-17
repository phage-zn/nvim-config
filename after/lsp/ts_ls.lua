return {
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
        includeInlayParameterNameHints = "all",     -- 'none' | 'literals' | 'all'
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayVariableTypeHints = true,
      },
    },
  },
  init_options = {
    preferences = {
      quotePreference = "single",
      includeCompletionsForModuleExports = true,
      includeCompletionsForImportStatements = true,
      importModuleSpecifierPreference = "non-relative",
      importModuleSpecifierEnding = "minimal",
    },
  },
}
