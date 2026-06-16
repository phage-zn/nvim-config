local utils = require("utilities.utils")
local gs = require("gitsigns")

return {
  { "-", "<cmd>Oil<cr>", desc = "Open Parent Dir" },
  { "<leader><leader>", "<cmd>Alpha<cr>", desc = "Dashboard", icon = "" },

  { "<leader>f", group = "Find" },
  { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
  { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find Word", mode = "n" },
  { "<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Find String", mode = "n" },
  { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files", mode = "n" },
  { "<leader>fc", "<cmd>Telescope colorscheme<cr>", desc = "Color Scheme", mode = "n" },
  { "<leader>fm", "<cmd>Telescope marks<cr>", desc = "Mark List", mode = "n" },
  { "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "Jump List", mode = "n" },
  { "<leader>fJc", function() require("utilities.jar-picker").pick_class() end,   desc = "Browse Dep Classes", mode = "n" },
  
  { "<leader>fJg", function() require("utilities.jar-picker").grep_deps() end,    desc = "Grep Dep Sources",   mode = "n" },
  { "<leader>f*", "<cmd>Telescope builtin<cr>", desc = "All Commands", mode = "n" },

  { "<leader>?", "<cmd>Telescope help_tags<cr>", desc = "Help Tags", mode = "n" },
  { "<leader>u", "<cmd>Telescope undo<cr>", desc = "Undo Tree", mode = "n" },

  { "<A-f>", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
  {
    "<A-x>",
    function()
      local buf = vim.api.nvim_get_current_buf()
      local buf_info = vim.fn.getbufinfo(buf)[1]
      local buffers = vim.fn.getbufinfo({ buflisted = 1 })

      local has_other = #buffers > 1

      if buf_info.changed == 1 then
        local response = vim.fn.confirm("Close modified buffer '" .. buf_info.name .. "'?", "&Yes\n&No", 1, "Warning")
        if not (response == 1) then
          vim.notify("Skipped: " .. buf_info.name)
          return
        end
      end

      if has_other then
        vim.cmd("bp")
      end

      vim.api.nvim_buf_delete(buf, { force = true })
    end,
    desc = "Delete Current Buffer",
  },
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
            local response = vim.fn.confirm("Close modified buffer '" .. buf.name .. "'?", "&Yes\n&No", 1, "Warning")
            if response == 1 then
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
  { "<A-h>", "<cmd>bp<cr>",                desc = "Go to Previous Buffer" },
  { "<A-l>", "<cmd>bn<cr>",                desc = "Go to Next Buffer" },
  { "<A-b>", "<cmd>Telescope buffers<cr>", desc = "List Buffers",         mode = "n" },
  {
    "<A-s>",
    function()
      vim.cmd("enew")
      vim.bo.buftype = "nofile"
      vim.bo.bufhidden = "wipe"
      vim.bo.buflisted = true
    end,
    desc = "New Scratch Buffer",
  },
  {
    "<A-o>",
    function()
      if vim.fn.bufnr("#") ~= -1 then
        vim.cmd("e#")
      else
        vim.notify("No alternate buffer")
      end
    end,
    desc = "Toggle Last Active Buffer",
  },
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
  { "<leader>tz", "<cmd>ZenMode<cr>", desc = "Zen Mode" },
  { "<F7>", "<cmd>ToggleTermToggleAll<cr>", desc = "Toggle Terminal", mode = "nt" },

  { "<leader>g", group = "Git" },
  { "<leader>gx", gs.toggle_current_line_blame, desc = "Toggle Current Line Blame" },
  {
    "<leader>gb",
    function()
      gs.blame_line({ full = true })
    end,
    desc = "Blame Line",
  },
  { "<leader>gB", gs.blame,       desc = "Blame buffer" },
  {
    "<leader>gl",
    utils.toggle_lazygit,
    desc = "Lazygit",
  },
  { "<leader>gc", gs.show_commit, desc = "Show commit" },
  { "<leader>gd", gs.diffthis,    desc = "Diff this" },
  {
    "<leader>gD",
    function()
      gs.diffthis("~")
    end,
    desc = "Diff this from previous commit",
  },

  { "<leader>q",  group = "Quickfix" },
  { "<leader>qo", "<cmd>copen<cr>",    desc = "Open" },
  { "<leader>qc", "<cmd>cclose<cr>",   desc = "Close" },
  { "<leader>qn", "<cmd>cnext<cr>",    desc = "Next" },
  { "<leader>qp", "<cmd>cprev<cr>",    desc = "Prev" },
  { "<leader>qh", "<cmd>chistory<cr>", desc = "History" },
  {
    "<leader>qd",
    function()
      local cmd = vim.fn.input("cdo: ")
      if cmd ~= "" then
        vim.cmd("cdo " .. cmd)
      end
    end,
    desc = "Run cmd on each item",
  },
  {
    "<leader>qf",
    function()
      local cmd = vim.fn.input("cfdo: ")
      if cmd ~= "" then
        vim.cmd("cfdo " .. cmd)
      end
    end,
    desc = "Run cmd on each file",
  },
  {
    "<leader>qa",
    function()
      vim.fn.setqflist({ { filename = vim.fn.expand("%"), lnum = vim.fn.line("."), text = vim.fn.getline(".") } }, "a")
    end,
    desc = "Add current line to quickfix",
  },
  { "gq", "<cmd>cnext<cr>", desc = "Next Quickfix Item" },
  { "gQ", "<cmd>cprev<cr>", desc = "Prev Quickfix Item" },

  { "<Esc>", "<cmd>nohlsearch<cr>", desc = "Clear Highlights" },
  { "<C-s>", "<cmd>w<cr>", desc = "Write Buffer" },
  { "<C-q><C-w>", "<cmd>confirm q<cr>", desc = "Confirm Quit Window" },
  { "<C-q>w", "<cmd>confirm q<cr>", desc = "Confirm Quit Window" },
  { "<C-q><C-q>", "<cmd>confirm qall<cr>", desc = "Confirm Quit All" },
  { "<C-q>q", "<cmd>confirm qall<cr>", desc = "Confirm Quit All" },
  { "<C-q><C-f>", "<cmd>qa!<cr>", desc = "Force Quit" },
  { "<C-q>f", "<cmd>qa!<cr>", desc = "Force Quit" },

  { "|", "<cmd>vsplit<cr>", desc = "Vertical Split" },
  { "\\", "<cmd>split<cr>", desc = "Horizontal Split" },

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
    function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end,
    desc = "Toggle Inlay Hints",
  },
  { "<leader>li", "<cmd>checkhealth vim.lsp<cr>", desc = "LSP Info", icon = "" },
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
  {
    "<leader>ll",
    function()
      vim.cmd("tabnew " .. vim.lsp.log.get_filename())
    end,
    desc = "Open Lsp Log"
  },
  { "<leader>lr", "<cmd>lsp restart<cr>", desc = "Lsp Restart" },
  { "<leader>ls", "<cmd>lsp stop<cr>", desc = "Lsp Stop" },

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
  {
    "<leader>d",
    group = "DAP",
  },
}
