return {
  check = function()
    vim.health.start("doing.nvim")
    local doing = require("doing")
    if doing.options ~= nil then
      vim.health.ok("Current task: " .. doing.current_task())
      vim.health.ok("Setup called. Options: " .. vim.inspect(doing.options))
    else
      vim.health.error("Setup not called")
    end
  end,
}
