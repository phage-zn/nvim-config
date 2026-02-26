return {
  { 'K', vim.lsp.buf.hover, desc = 'Hover Documentation' },

  { "<leader>l", group = "LSP", icon = '󱁼' },
  { "<leader>lf", vim.lsp.buf.format, desc = 'Format Buffer' },
  { "<leader>lh", '<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<cr>', desc = 'Toggle Inlay Hints' },
  { "<leader>li", '<cmd>LspInfo<cr>', desc = 'LSP Info', icon = "" },
  { "<leader>l?", vim.lsp.buf.signature_help, desc = 'Signature Help', icon = "󰋖" },
  { "<leader>ld", "<cmd>Telescope diagnostics<cr>", desc = 'Diagnostics', icon = '' },
  { "<leader>lt", "<cmd>Telescope lsp_type_definitions<cr>", desc = 'Type Definition', icon = '' },

  { "g", group = "Go To" },
  { "gd", vim.lsp.buf.definition, desc = 'Goto Definition' },
  { "gj", function() vim.diagnostic.jump({ count = 1, float = true }) end, desc = 'Goto Next Diagnostic' },
  { "gk", function() vim.diagnostic.jump({ count = -1, float = true }) end, desc = 'Goto Prev Diagnostic' },
}
