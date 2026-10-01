local action_state = require "telescope.actions.state"
local finders = require "telescope.finders"

local actions = {}

actions.filter_files = function(prompt_bufnr)
  local results = {}
  local opts = {
    reset_prompt = false
  }
  local current_picker = action_state.get_current_picker(prompt_bufnr)
  for entry in current_picker.manager:iter() do
    table.insert(results, entry)
  end
  local new_finder = finders.new_table {
    results = results,
    entry_maker = function(x)
      return x
    end,
  }
  current_picker:refresh(new_finder, opts)
end

return actions
