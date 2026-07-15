return {
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
      filetypes = {
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'vue',
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
        -- tsserver = {
        --   logVerbosity = 'verbose',
        --   trace = 'verbose',
        -- },
        plugins = {
          {
            name = "@vue/typescript-plugin",
            location = '/home/lms/.local/share/nvim/mason/packages/vue-language-server',
            languages = { "javascript", "typescript", "vue" },
          },
        },
      },
    },
    vue_ls = {},
    eslint = {
      settings = {
        codeActionOnSave = {
          enable = true,
          mode = "all"
        },
        run = 'onSave',
        workingDirectory = { mode = "location" }
      },
    },
    yamlls = {
      settings = {
        schemas = {
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
          ["https://json.schemastore.org/github-action.json"] = "action.yml",
        }
      }
    },
    copilot = {
      cmd = { "copilot-language-server", "--stdio" },
      filetypes = { "*" },
      root_markers = { ".git" },
    }
  },
}
