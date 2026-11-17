local java_install_dir = vim.fn.expand "$SDKMAN_DIR/candidates/java/"
local function get_jdtls_cache_dir()
  return vim.fn.stdpath('cache') .. '/jdtls'
end

local function get_jdtls_workspace_dir()
  return get_jdtls_cache_dir() .. '/workspace'
end
local bundles = {
  vim.fn.expand "$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar",
}

local java_test_bundles = vim.split(vim.fn.glob("$MASON/share/java-test/*.jar", true), "\n")
local excluded = {
  "com.microsoft.java.test.runner-jar-with-dependencies.jar",
  "jacocoagent.jar",
}
for _, java_test_jar in ipairs(java_test_bundles) do
  local fname = vim.fn.fnamemodify(java_test_jar, ":t")
  if not vim.tbl_contains(excluded, fname) then
    table.insert(bundles, java_test_jar)
  end
end

---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local workspace_dir = get_jdtls_workspace_dir()
    local data_dir = workspace_dir

    if config.root_dir then
      data_dir = data_dir .. '/' .. vim.fn.fnamemodify(config.root_dir, ':p:h:t')
    end

    local config_cmd = {
      'jdtls',
      "--java-executable",
      java_install_dir .. "25.0.5.0+8-tem/bin/java",
      '-data',
      data_dir,
      "--jvm-arg=-javaagent:" .. vim.fn.expand "$MASON/share/jdtls/lombok.jar",
    }

    return vim.lsp.rpc.start(config_cmd, dispatchers, {
      cwd = config.cmd_cwd,
      env = config.cmd_env,
      detached = config.detached,
    })
  end,
  init_options = {
    bundles = bundles,
  },
  settings = {
    java = {
      home = java_install_dir .. "21.0.2-open/bin/java",
      inlayHints = { parameterNames = { enabled = 'all' } },
      project = {
        referencedLibraries = {
          indlude = {
            'estonia_interactive'
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
            path = java_install_dir .. "17.0.18-tem",
            default = true
          },
          {
            name = "JavaSE-1.8",
            path = java_install_dir .. "8.0.482-tem",
          },
          {
            name = "JavaSE-21",
            path = java_install_dir .. "21.0.2-open",
          },
          {
            name = "JavaSE-25",
            path = java_install_dir .. "25.0.2-open",
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
      },
      signatureHelp = {
        enabled = true,
      },
      completion = {
        matchCase = "off",
      },
    },
  },
}
