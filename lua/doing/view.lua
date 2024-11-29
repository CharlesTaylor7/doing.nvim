local state = require("doing.state")
local utils = require("doing.utils")

local View = {}

---Create a winbar string for the current task
function View.status()
  if (not state.view_enabled) or (not utils.should_display_task()) then
    return ""
  end

  local right = ""

  -- using pcall so that it won't spam error messages
  local ok, left = pcall(function()
    local count = state.tasks:count()
    local res = ""
    local current = state.tasks:current()

    if state.message then
      return state.message
    end

    if count == 0 then
      return ""
    end

    return state.options.doing_prefix .. current
  end)

  if not ok then
    return "ERR: " .. left
  end

  if not right then
    return left
  end

  return left .. "  " .. right
end

View.stl = "%!v:lua.DoingStatusline('active')"

return View
