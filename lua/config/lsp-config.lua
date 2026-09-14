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
    biome = {
      settings = {
        formatter = {
          indentStyle = 'space',
          quoteStyle = 'single'
        }
      },
      filetypes = {
        'json',
        'jsonc',
      },
      workspace_required = false,
      root_dir = function(bufnr, on_dir)
        local root_markers = {
          'package-lock.json',
          'yarn.lock',
          'pnpm-lock.yaml',
          'bun.lockb',
          'bun.lock',
          'deno.lock',
          'biome.json',
          'biome.jsonc',
          '.git'
        }

        local lsp_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
        on_dir(lsp_root)
      end,
    }
  },
}
