local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", ".project" }
local root_dir = require("jdtls.setup").find_root(root_markers)
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath "data" .. "/site/java/workspace-root/" .. project_name
vim.fn.mkdir(workspace_dir, "p")
local jdtls = require('jdtls')
local jvm = vim.fn.expand "$SDKMAN_DIR/candidates/java/"

local config = {
  cmd = {
    jvm .. "21.0.2-open/bin/java",
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
  root_dir = root_dir,
  settings = {
    java = {
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
