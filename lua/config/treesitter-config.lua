return {
  treesitter = {
    languages = {
      "java",
      "lua",
      "rust",
      "zig",
      "c",
      "html",
      "yaml",
      "javascript",
      "typescript",
      "vimdoc",
      "vim",
      "bash",
      "regex",
      "markdown",
      "markdown_inline",
    },
  },

  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["gm"] = "@function.outer",
        ["go"] = "@class.outer",
      },
      goto_next_end = {
        ["gw"] = "@function.outer",
        ["]C"] = "@class.outer",
      },
      goto_previous_start = {
        ["gM"] = "@function.outer",
        ["gO"] = "@class.outer",
      },
      goto_previous_end = {
        ["gW"] = "@function.outer",
        ["[C"] = "@class.outer",
      },
    },
  },
}
