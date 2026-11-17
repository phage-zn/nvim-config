return {
  init_options = {
    biome = {
      configurationPath = "~/.config/nvim/lua/config/biome-config.json"
    }
  },
  settings = {
    formatter = {
      indentStyle = 'space',
      quoteStyle = 'single'
    }
  },
  filetypes = {
    'json',
    'jsonc',
  },
  workspace_required = false,
  root_dir = function(bufnr, on_dir)
    local root_markers = {
      'package-lock.json',
      'yarn.lock',
      'pnpm-lock.yaml',
      'bun.lockb',
      'bun.lock',
      'deno.lock',
      'biome.json',
      'biome.jsonc',
      '.git'
    }

    local lsp_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
    on_dir(lsp_root)
  end,
}
