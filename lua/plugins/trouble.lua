return {
  "folke/trouble.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function(_, opts)
    require('trouble').setup(opts)
    vim.api.nvim_create_autocmd("QuickFixCmdPost", {
      callback = function()
        vim.cmd([[Trouble qflist open]])
      end,
    })
  end,
  opts = {
    modes = {
      symbols = {
        desc = "document symbols",
        mode = "lsp_document_symbols",

        focus = false,
        win = {
          position = "right",
          size = 0.25,
        },
        preview = {
          type = "split",
          relative = "win",
          size = 0.3,
        },
        filter = {
          -- remove Package since luals uses it for control flow structures
          ["not"] = { ft = "lua", kind = "Package" },
          any = {
            -- all symbol kinds for help / markdown files
            ft = { "help", "markdown" },
            -- default set of symbol kinds
            kind = {
              "Class",

              "Constructor",

              "Enum",
              "Field",
              "Function",

              "Interface",
              "Method",
              "Module",
              "Namespace",
              "Package",
              "Property",
              "Struct",
              "Trait",
            },

          },
        },
      },
    }
  },
}
