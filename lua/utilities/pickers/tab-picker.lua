local M = {}

local pickers       = require("telescope.pickers")
local finders       = require("telescope.finders")
local conf          = require("telescope.config").values
local actions       = require("telescope.actions")
local action_state  = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local utils         = require("telescope.utils")
local strings       = require("plenary.strings")
local Path          = require("plenary.path")

M.tabs = function(opts)
  opts = opts or {}
  local tabs = {}
  for _, tabinfo in ipairs(vim.fn.gettabinfo()) do
    local element = {}
    element.tabnr = tabinfo.tabnr
    element.windows = vim.tbl_filter(function(winid)
      local wininfo = vim.fn.getwininfo(winid)[1]
      local should_add = true
      if wininfo.quickfix == 1 or wininfo.winnr == 0 then
        should_add = false
      end
      return should_add
    end, tabinfo.windows)
    element.active_win = vim.api.nvim_tabpage_get_win(tabinfo.tabnr)
    element.active_buf = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(element.active_win))
    table.insert(tabs, element)
  end
  local i, _ = utils.get_devicons("fname", false)
  local icon_width = strings.strdisplaywidth(i)
  local displayer = entry_display.create {
    separator = " ",
    items = {
      { width = 7 },
      { width = 2 },
      { width = icon_width },
      { remaining = true },
    },
  }
  local cwd = utils.path_expand(vim.uv.cwd())
  local make_display = function(entry)
    local icon, hl_group = utils.get_devicons(entry.active_buf, false)
    local bufname = entry.active_buf and Path:new(entry.active_buf):normalize(cwd) or "[No Name]"
    return displayer {
      { "Tab: " .. entry.tabnr, "TelescopeResultsIdentifier" },
      { entry.num_windows,      "TelescopeResultsComment" },
      { icon,                   hl_group },
      { bufname }
    }
  end

  pickers.new(opts, {
    prompt_title = "Tabs",
    finder = finders.new_table {
      results = tabs,
      entry_maker = function(entry)
        return {
          tabnr = entry.tabnr,
          num_windows = #entry.windows,
          value = entry.tabnr,
          active_buf = entry.active_buf,
          ordinal = "Tab: " .. entry.tabnr .. " | Open Windows: " .. #entry.windows,
          display = make_display,
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.cmd('tabn ' .. selection.value)
      end)
      return true
    end,
    default_selection_index = 1,
  }):find()
end

return M
