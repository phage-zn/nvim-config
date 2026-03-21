return {
  { "K", vim.lsp.buf.hover, desc = "Hover Documentation" },

  { "<leader>l", group = "LSP", icon = "󱁼" },
  {
    "<leader>lf",
    function()
      vim.lsp.buf.format({ async = true })
    end,
    desc = "Format Buffer",
  },
  {
    "<leader>lh",
    "<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<cr>",
    desc = "Toggle Inlay Hints",
  },
  { "<leader>li", "<cmd>LspInfo<cr>", desc = "LSP Info", icon = "" },
  { "<leader>l?", vim.lsp.buf.signature_help, desc = "Signature Help", icon = "󰋖" },
  { "<leader>ld", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics", icon = "" },
  { "<leader>lt", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Type Definition", icon = "" },
  {
    "<leader>lx",
    "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
    desc = "Toggle buffer diagnostics",
    icon = "",
  },
  { "<leader>lX", "<cmd>Trouble diagnostics toggle<cr>", desc = "Toggle diagnostics", icon = "" },

  { "g", group = "Go To" },
  { "gd", vim.lsp.buf.definition, desc = "Go to Definition" },
  {
    "gj",
    function()
      vim.diagnostic.jump({ count = 1, float = true })
    end,
    desc = "Go to Next Diagnostic",
  },
  {
    "gk",
    function()
      vim.diagnostic.jump({ count = -1, float = true })
    end,
    desc = "Go to Prev Diagnostic",
  },
}
