local jvm = vim.fn.expand "$SDKMAN_DIR/candidates/java/"
local function get_jdtls_cache_dir()
  return vim.fn.stdpath('cache') .. '/jdtls'
end

local function get_jdtls_workspace_dir()
  return get_jdtls_cache_dir() .. '/workspace'
end
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
    },
    jdtls = {
      init_options = {
        bundles = {
          vim.fn.expand "$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar",
        },
      },
      cmd = function(dispatchers, config)
        local workspace_dir = get_jdtls_workspace_dir()
        local data_dir = workspace_dir

        if config.root_dir then
          data_dir = data_dir .. '/' .. vim.fn.fnamemodify(config.root_dir, ':p:h:t')
        end

        local config_cmd = {
          'jdtls',
          "--java-executable",
          jvm .. "21.0.2-open/bin/java",
          "--jvm-arg=-javaagent:" .. vim.fn.expand "$MASON/share/jdtls/lombok.jar",
          '-data',
          data_dir,
        }

        return vim.lsp.rpc.start(config_cmd, dispatchers, {
          cwd = config.cmd_cwd,
          env = config.cmd_env,
          detached = config.detached,
        })
      end,
      settings = {
        java = {
          jdt = {
            ls = {
              java = {
                home = { jvm .. "21.0.2-open/bin/java" },
              }
            }
          },
          inlayHints = { parameterNames = { enabled = 'all' } },
          project = {
            referencedLibraries = {
              indlude = {
                'com.rogue', 'co.octopus'
              }
            }
          },
          -- quickfix?: QuickFixOption;
          references = {
            includeAccessors = true,
            includeDecompiledSources = true,
          },
          eclipse = {
            downloadSources = true,
          },
          maven = {
            downloadSources = true,
          },
          implementationsCodeLens = {
            enabled = true,
          },
          referencesCodeLens = {
            enabled = true,
          },
          configuration = {
            updateBuildConfiguration = 'interactive',
            runtimes = {
              {
                name = "JavaSE-17",
                path = jvm .. "17.0.18-tem",
                default = true
              },
              {
                name = "JavaSE-1.8",
                path = jvm .. "8.0.482-tem",
              },
              {
                name = "JavaSE-21",
                path = jvm .. "21.0.2-open",
              },
              {
                name = "JavaSE-25",
                path = jvm .. "25.0.2-open",
              },
            },
          },
          format = {
            enabled = true,
            tabSize = 4,
            insertSpaces = true,
            comments = {
              enabled = true,
            },
            settings = {
              url = vim.fn.expand "$HOME/octopus-eclipse-style.xml"
            },
          },
          signatureHelp = {
            enabled = true,
          },
          cleanup = {
            actionsOnSave = {
              "qualifyMembers",
              "qualifyStaticMembers",
              "addOverride",
              "addDeprecated",
              "stringConcatToTextBlock",
              "invertEquals",
              "addFinalModifier",
              "instanceofPatternMatch",
              "lambdaExpression",
              "switchExpression"
            }
          },
          saveActions = {
            organizeImports = true,
          },
          completion = {
            matchCase = "off",
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.assertThat",
              "org.hamcrest.Matchers.*",
              "org.hamcrest.CoreMatchers.*",
              "org.junit.jupiter.api.Assertions.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
              "org.mockito.Mockito.*",
            },
            importOrder = {
              "java",
              "javax",
              "com",
              "org",
              "junit",
              "junitx",
              "lombok",
              "gamesys",
              "gamesys.baltics.games",
              "co.octopus",
              "estonia_interactive",
              "com.utilities",
              "com.rogue.common",
              "com.rogue.charon",
              "com.rogue",
              "",
              "#com",
              "#org",
              "#junit",
              "#junitx",
              "#lombok",
              "#gamesys",
              "#gamesys.baltics.games",
              "#co.octopus",
              "#estonia_interactive",
              "#com.utilities",
              "#com.rogue.common",
              "#com.rogue.charon",
              "#com.rogue",
              "#",
            }
          },
          sources = {
            organizeImports = {
              starThreshold = 5,
              staticStarThreshold = 2,
            },
          },
        },
      },
    },
  },
}
