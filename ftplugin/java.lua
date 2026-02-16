local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", ".project" }
local root_dir = require("jdtls.setup").find_root(root_markers)
-- calculate workspace dir
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath "data" .. "/site/java/workspace-root/" .. project_name
os.execute("mkdir " .. workspace_dir)
local jdtls = require('jdtls')
local jvm = "/usr/lib/jvm/"

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
-- TODO: Move to config
local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {
    vim.fn.expand(jvm .. "java-21-openjdk/bin/java"),
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-javaagent:" .. vim.fn.expand "$MASON/share/jdtls/lombok.jar",
    "-Xms1g",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    vim.fn.glob("$MASON/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
    "-configuration",
    vim.fn.expand "$MASON/packages/jdtls/config_linux",
    "-data",
    workspace_dir,
  },
  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = root_dir,

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      inlayHints = { parameterNames = { enabled = 'all' } },
      references = {
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
            path =
                jvm .. "java-17-openjdk/",
            default = true
          },
          {
            name = "JavaSE-1.8",
            path =
                jvm .. "java-8-openjdk/",
          },
          {
            name = "JavaSE-21",
            path =
                jvm .. "java-21-openjdk/",
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
        onType = {
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
  on_attach = function()
    local keymaps = require("config.lsp-keymaps")
    require("which-key").add(keymaps)
  end,


  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = {
      vim.fn.expand "$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar",
    },
  },
}

config.on_init = function(client, _)
  client.notify('workspace/didChangeConfiguration', { settings = config.settings })
end
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
jdtls.start_or_attach(config)
