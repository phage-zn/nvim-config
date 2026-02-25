local gs = package.loaded.gitsigns

return {
  { "-", "<cmd>Oil<cr>", desc = "Open Parent Dir" },
  { "<leader><leader>", "<cmd>Alpha<cr>", desc = "Dashboard", icon = "" },

  -- Telescope Functions
  { "<leader>f", group = "Find" },
  { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
  { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files", mode = "n" },
  { "<leader>fc", "<cmd>Telescope colorscheme<cr>", desc = "Color Scheme", mode = "n" },
  { "<leader>f*", "<cmd>Telescope builtin<cr>", desc = "All Commands", mode = "n" },

  -- Search Functions
  { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find Word", mode = "n" },
  { "<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Find String", mode = "n" },

  { "<leader>?", "<cmd>Telescope help_tags<cr>", desc = "Help Tags", mode = "n" },
  { "<leader>b", "<cmd>Telescope buffers<cr>", desc = "Switch Buffer", mode = "n" },
  { "<leader>u", "<cmd>Telescope undo<cr>", desc = "Undo Tree", mode = "n" },

  { "<A-x>", "<cmd>bp | bd #<cr>", desc = "Delete Current Buffer" },
  {
    "<A-X>",
    function()
      local buffers = vim.fn.getbufinfo({ buflisted = 1 })
      local count = 0
      local skip_count = 0
      local notification = "Closed %d buffer(s)."
      local skip_notification = " Skipped %d modified buffer(s)."
      for _, buf in ipairs(buffers) do
        if buf.hidden == 1 then
          if buf.changed == 1 then
            local response = vim.fn.input("Close modified buffer '" .. buf.name .. "'? (Y/n): ")
            if response == "" or response:lower() == "y" then
              vim.api.nvim_buf_delete(buf.bufnr, { force = true })
              count = count + 1
            else
              vim.notify("Skipped: " .. buf.name)
              skip_count = skip_count + 1
            end
          else
            vim.api.nvim_buf_delete(buf.bufnr, { force = false })
            count = count + 1
          end
        end
      end
      local message = string.format(notification, count)
      if skip_count > 0 then
        message = message .. string.format(skip_notification, skip_count)
      end
      vim.notify(message)
    end,
    desc = "Delete Other Buffers",
  },
  { "<A-h>", "<cmd>bp<cr>", desc = "Go to Previous Buffer" },
  { "<A-l>", "<cmd>bn<cr>", desc = "Go to Next Buffer" },
  { "<A-o>", "<cmd>e#<cr>", desc = "Toggle Last Active Buffer" },
  { "<A-t>", "<cmd>tabnew<cr>", desc = "Create New Tab" },
  { "<A-w>", "<cmd>tabc<cr>", desc = "Close Tab" },

  -- Plugin Functions
  { "<leader>p", group = "Plugins", icon = "" },
  { "<leader>pm", "<cmd>Mason<cr>", desc = "Open Mason LSP Plugin Manager" },
  { "<leader>pl", "<cmd>Lazy<cr>", desc = "Open Lazy Plugin Manager" },

  -- ToggleTerm Functions
  { "<leader>t", group = "Terminal" },
  { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Float" },
  { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Horizontal" },
  { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Vertical" },
  { "<F7>", "<cmd>ToggleTermToggleAll<cr>", desc = "Toggle Terminal", mode = "nt" },

  { "<leader>g", group = "Git" },
  { "<leader>gb", gs.toggle_current_line_blame, desc = "Toggle Current Line Blame" },
  {
    "<leader>gB",
    function()
      gs.blame_line({ full = true })
    end,
    desc = "Toggle Full Line Blame",
  },
  {
    "<leader>gl",
    function()
      local terminal = require("toggleterm.terminal").Terminal
      local lazygit = terminal:new({ cmd = "lazygit", hidden = true, direction = "float" })
      lazygit:toggle()
    end,
    desc = "Lazygit",
  },
  {
    "<leader>gc",
    function()
      gs.show_commit()
    end,
    desc = "Show commit",
  },

  -- Vim Built-In Functions
  { "<Esc>", "<cmd>nohlsearch<cr>", desc = "Clear Highlights" },
  { "<C-s>", "<cmd>w<cr>", desc = "Write" },
  { "<C-s>a", "<cmd>wa<cr>", desc = "Write All" },
  { "<C-q>b", "<cmd>confirm bd<cr>", desc = "Confirm Quit Buffer" },
  { "<C-q>w", "<cmd>confirm q<cr>", desc = "Confirm Quit Window" },
  { "<C-q>q", "<cmd>confirm qall<cr>", desc = "Confirm Quit All" },
  { "<C-q>f", "<cmd>qa!<cr>", desc = "Force Quit" },

  { "|", "<cmd>vsplit<cr>", desc = "Vertical Split" },
  { "\\", "<cmd>split<cr>", desc = "Horizontal Split" },

  -- LSP Keymaps
  { "K", vim.lsp.buf.hover, desc = "Hover Documentation" },

  { "<leader>l", group = "LSP", icon = "󱁼" },
  { "<leader>lf", vim.lsp.buf.format, desc = "Format Buffer" },

  {
    "<leader>lh",
    "<cmd>lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<cr>",
    desc = "Toggle Inlay Hints",
  },
  { "<leader>li", "<cmd>LspInfo<cr>", desc = "LSP Info", icon = "" },
  { "<leader>l?", vim.lsp.buf.signature_help, desc = "Signature Help", icon = "󰋖" },
  { "<leader>ld", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics", icon = "" },
  { "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols", icon = "" },
  { "<leader>lt", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Type Definition", icon = "" },

  { "g", group = "Go To" },
  { "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
  { "gj", function () vim.diagnostic.jump({ count = 1, float = true }) end, desc = "Goto Next Diagnostic" },
  { "gk", function () vim.diagnostic.jump({ count = -1, float = true }) end, desc = "Goto Prev Diagnostic" },
}
