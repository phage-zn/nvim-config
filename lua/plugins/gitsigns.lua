return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },

    numhl = true,
    current_line_blame = true,
    current_line_blame_opts = {},
    gh = true,
  },
}
