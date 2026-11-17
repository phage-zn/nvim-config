return {
  {
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
      local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
      local servers = {
        "biome", "eslint", "jdtls", "lua_ls", "ts_ls", "yamlls"
      }
      vim.lsp.config("*", {
        capabilities = lsp_capabilities,
      })

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = servers,
      })
    end,
  },
  { "mfussenegger/nvim-jdtls" },
}
