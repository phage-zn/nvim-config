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
      local lsp_capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
      vim.lsp.config("*", {
        capabilities = lsp_capabilities,
      })

      require("mason").setup()
      local mason_config = require("config.mason-config")
      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(mason_config.servers)
      })

      for server_name, server_config in pairs(mason_config.servers) do
        vim.lsp.config(server_name, {
          settings = server_config.settings,
          init_options = (server_config.init_options and server_config.init_options[server_name]) or {},
        })
      end
    end
  },
  { "mfussenegger/nvim-jdtls" },
}
