local b_utils = require("utilities.buffers")
local utils = require("utilities.utils")
local gs = require("gitsigns")
local ts = require("utilities.treesitter-textobjects.utils")
local terminal = require("toggleterm.terminal").Terminal

local lazygit = terminal:new({
  cmd = "lazygit",
  dir = "git_dir",
  hidden = true,
  direction = "float",
  on_open = function(term)
    vim.cmd("startinsert!")
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
  end
})

local function toggle_lazygit()
  lazygit:toggle(vim.o.columns * 0.3)
end

return {
  { "-", "<cmd>Oil<cr>", desc = "Open Parent Dir" },
  { "<leader><leader>", "<cmd>Alpha<cr>", desc = "Dashboard", icon = "" },

  { "<leader>f", group = "Find" },
  { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
  { "<leader>ft", function() require("utilities.pickers.tab-picker").tabs() end, desc = "Find Tabs", mode = "n" },
  { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find Word", mode = "n" },
  { "<leader>fs", "<cmd>Telescope live_grep<cr>", desc = "Find String", mode = "n" },
  { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files", mode = "n" },
  { "<leader>fc", "<cmd>Telescope colorscheme<cr>", desc = "Color Scheme", mode = "n" },
  { "<leader>fm", "<cmd>Telescope lsp_document_symbols symbols={'method','function'}<cr>", desc = "Find Method", mode = "n" },
  { "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "Jump List", mode = "n" },

  { "<leader>f*", "<cmd>Telescope builtin<cr>", desc = "All Commands", mode = "n" },

  { "<leader>?", "<cmd>Telescope help_tags<cr>", desc = "Help Tags", mode = "n" },
  { "<leader>u", "<cmd>Telescope undo<cr>", desc = "Undo Tree", mode = "n" },

  { "<A-f>", "<cmd>Telescope find_files<cr>", desc = "Find File", mode = "n" },
  {
    "<A-x>",
    function()
      local buf = vim.api.nvim_get_current_buf()
      local buffers = vim.fn.getbufinfo({ buflisted = 1 })
      buffers = vim.tbl_filter(function(b)
        return b.bufnr ~= buf
      end, buffers)

      if vim.bo[buf].modified then
        local name = vim.fn.bufname(buf)
        local choices = {"Yes", "No", "Cancel"}
        local choice = utils.confirm("Save changes to '" .. (name == "" and "Untitled" or name) .. "'?", choices)
        if choice == nil or choice == "Cancel" then
          return
        end
        if choice == "Yes" then
          vim.api.nvim_buf_call(buf, vim.cmd.write)
        end
      end

      table.sort(buffers, function(a, b)
        return a.lastused > b.lastused
      end)

      if buffers[1] then
        vim.cmd("b" .. buffers[1].bufnr)
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
      buffers = vim.tbl_filter(function(buf)
        return buf.hidden == 1
      end, buffers)

      for _, buffer in ipairs(buffers) do
        local buf = buffer.bufnr
        if vim.bo[buf].modified then
          local name = vim.fn.bufname(buf)
          local choices = {"Yes", "No", "Skip", "Open", "Cancel"}
          local choice = utils.confirm("Save changes to '" .. (name == "" and "Untitled" or name) .. "'?", choices)
          if choice == nil or choice == "Cancel" then
            return
          elseif choice == "Open" and buf > 0 then
            vim.cmd.b { buf }
            return
          elseif choice == "Skip" then
            skip_count = skip_count + 1
            break;
          elseif choice == "Yes" then
            vim.api.nvim_buf_call(buf, vim.cmd.write)
          end
        end
        count = count + 1
        vim.api.nvim_buf_delete(buf, { force = true })
      end

      local message = string.format(notification, count)
      if skip_count > 0 then
        message = message .. string.format(skip_notification, skip_count)
      end
      pcall(vim.notify, message, vim.log.levels.INFO, "Closed buffers")
    end,
    desc = "Delete Hidden Buffers",
  },
  { "<A-h>", "<cmd>bp<cr>",                desc = "Go to Previous Buffer" },
  { "<A-l>", "<cmd>bn<cr>",                desc = "Go to Next Buffer" },
  { "<A-b>", "<cmd>Telescope buffers<cr>", desc = "List Buffers",         mode = "n" },
  { "<A-n>", "<cmd>enew<cr>",              desc = "New File",         mode = "n" },
  {
    "<A-N>",
    function ()
      pcall(vim.ui.input, {
        prompt = "Enter filename:",
        scope = 'cursor'
      },
      function (input)
        b_utils.openBuffer({
          name = input,
        })
      end)
    end,
    desc = "New File",
    mode = "n"
  },
  {
    "<A-s>",
    function()
      b_utils.openBuffer({
        name = "Scratch",
        bufOpts = {
          buftype = 'nofile',
          swapfile = false,
          bufhidden = 'hide',
        }
      })
    end,
    desc = "New Scratch Buffer",
  },
  {
    "<A-S>",
    function ()
      pcall(vim.ui.select,
      vim.fn.getcompletion('', 'filetype'),
      {
        prompt = "Enter filetype:",
        scope = 'window',
        completion = 'filetype'
      },
      function (input)
        if (input == nil) then
          return
        end
        b_utils.openBuffer({
          name = "Scratch",
          bufOpts = {
            buftype = 'nofile',
            swapfile = false,
            bufhidden = 'hide',
            filetype = input or 'text'
          }
        })
      end)
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
  { "<leader>ta", "<cmd>Atac<cr>", desc = "Atac" },
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
    function ()
      toggle_lazygit()
    end,
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
  { "<leader>qh", "<cmd>chistory<cr>", desc = "History" },
  {
    "<leader>qd",
    function()
      vim.ui.input({ prompt = "[Entry] cmd: " }, function (input)
        if input ~= "" then
          vim.cmd("cdo " .. input)
        end
      end)
    end,
    desc = "Run cmd on each entry",
  },
  {
    "<leader>qf",
    function()
      vim.ui.input({ prompt = "[File] cmd: " }, function (input)
        if input ~= "" then
          vim.cmd("cfdo " .. input)
        end
      end)
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

  {
    "<Esc>",
    "<Cmd>nohlsearch<Bar>diffupdate<Bar>call nvim_buf_clear_namespace(0, nvim_create_namespace('nvim.multicursor'), 0, -1) <CR>",
    desc = "Clear Highlights"
  },
  {
    "<C-s>",
    function()
      local buf = vim.api.nvim_get_current_buf()
      b_utils.write(buf)
    end,
    desc = "Write Buffer"
  },
  { "<C-q><C-w>", "<cmd>confirm q<cr>", desc = "Confirm Quit Window" },
  { "<C-q>w", "<cmd>confirm q<cr>", desc = "Confirm Quit Window" },
  { "<C-q><C-q>", "<cmd>confirm qall<cr>", desc = "Confirm Quit All" },
  { "<C-q>q", "<cmd>confirm qall<cr>", desc = "Confirm Quit All" },
  { "<C-q><C-f>", "<cmd>qa!<cr>", desc = "Force Quit" },
  { "<C-q>f", "<cmd>qa!<cr>", desc = "Force Quit" },

  { "|", "<cmd>vsplit<cr>", desc = "Vertical Split" },
  { "\\", "<cmd>split<cr>", desc = "Horizontal Split" },

  { "K", function()
    --- @type vim.lsp.buf.hover.Opts
    local config = {
      border="rounded"
    }
    vim.lsp.buf.hover(config)
  end, desc = "Hover Documentation" },

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
  { "<leader>lq", "<cmd>lsp stop<cr>", desc = "Lsp Stop" },

  { "g", group = "Go To" },
  { "gd", vim.lsp.buf.definition, desc = "Go to Definition" },
  {
    "gj",
    function()
      vim.diagnostic.jump({ count = 1, float = true })
    end,
    desc = "Next Diagnostic",
  },
  {
    "gk",
    function()
      vim.diagnostic.jump({ count = -1, float = true })
    end,
    desc = "Prev Diagnostic",
  },
  { "gO", "<cmd>Trouble symbols toggle<cr>", desc = "Lsp Symbols" },
  {
    mode = { "x", "o" },
    { "am", function() ts.select("@function.outer") end, desc = "Select Around Function" },
    { "im", function() ts.select("@function.inner") end, desc = "Select In Function" },
    { "ac", function() ts.select("@class.outer") end, desc = "Select Around Class" },
    { "ic", function() ts.select("@class.inner") end, desc = "Select In Class" },
    { "aa", function() ts.select("@parameter.outer") end, desc = "Select In Parameter" },
    { "ia", function() ts.select("@parameter.inner") end, desc = "Select In Parameter" },
  },
  {
    mode = { "n", "x", "o" },
    { "]m", function() ts.goto("@function.outer") end, desc = "Go To Next Function" },
    { "[m", function() ts.goto("@function.outer", { direction = "previous" }) end, desc = "Go To Previous Function" },
    { "]M", function() ts.goto("@function.outer", { position = "end" }) end, desc = "Go To Next Function End" },
    { "[M", function() ts.goto("@function.outer", { direction = "previous", position = "end" }) end, desc = "Go To Previous Function End" },

    { "]c", function() ts.goto("@class.outer") end, desc = "Go To Next Class" },
    { "[c", function() ts.goto("@class.outer", { direction = "previous" }) end, desc = "Go To Previous Class" },
    { "]C", function() ts.goto("@class.outer", { position = "end" }) end, desc = "Go To Next Class End" },
    { "[C", function() ts.goto("@class.outer", { direction = "previous", position = "end" }) end, desc = "Go To Previous Class End" },
  },
  {
    mode = { "n" },
    { "<leader>ln", function() ts.swap("@parameter.inner") end, desc = "Swap parameter with next" },
    { "<leader>lp", function() ts.swap("@parameter.inner", { direction = "previous" }) end, desc = "Swap parameter with previous" },
  },
  {
    "<leader>d",
    group = "DAP",
  },
  {
    "<leader>du",
    function()
      require("dapui").toggle({})
    end,
    desc = "Dap UI",
  },
  {
    "<leader>db",
    "<cmd>DapToggleBreakpoint<cr>",
    desc = "Toggle Breakpoint",
  },
  {
    "<leader>dc",
    "<cmd>DapContinue<cr>",
    desc = "Continue",
  },
  {
    "<leader>dC",
    function()
      require("dap").run_to_cursor()
    end,
    desc = "Run to Cursor",
  },
  {
    "<leader>dt",
    function()
      pcall(vim.ui.select, {"Test Class", "Test Method", "Pick Test"},
      {
        prompt = "Choose Test To Run:",
      },
      function (input)
        if (input == nil) then
          return
        end
        if input == "Test Class" then
          require('jdtls').test_class()
        elseif input == "Test Method" then
          require('jdtls').test_nearest_method()
        elseif input == "Pick Test" then
          require('jdtls').pick_test()
        end
      end)
    end,
    desc = "Run to Cursor",
  },
  {
    "<leader>dp",
    "<cmd>DapPause<cr>",
    desc = "Pause",
  },
  {
    "<leader>ds",
    function()
      require("dap").close()
    end,
    desc = "Stop",
  },
  {
    "<leader>dT",
    "<cmd>DapTerminate<cr>",
    desc = "Terminate",
  },
}
