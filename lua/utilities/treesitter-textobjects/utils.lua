local M = {}

---@class JumpOpts
---@field position? "start" | "end" | "nearest"
---@field group? string
---@field direction? "previous" | "next"

---@param object string
---@param opts? JumpOpts
function M.goto(object, opts)
  local ts = require("nvim-treesitter-textobjects.move")
  local position = opts and opts.position or "start"
  local direction = opts and opts.direction or "next"
  local group = opts and opts.group or "textobjects"
  local fn = "goto_" .. direction .. "_" .. position
  if ts[fn] then
    ts[fn](object, group)
  else
    vim.notify(fn .. " does not exist")
  end
end


---@class SelectOpts
---@field group? string

---@param object string
---@param opts? SelectOpts
function M.select(object, opts)
  local ts = require("nvim-treesitter-textobjects.select")
  local group = opts and opts.group or "textobjects"
  ts.select_textobject(object, group)
end


return M
