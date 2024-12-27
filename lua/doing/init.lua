--- A tinier task manager that helps you stay on track.
local M = {}

--- Add a task to the list
function M.add(task, to_front)
  if to_front then
    vim.api.nvim_buf_set_lines(M.tasks_bufnr, 0, 0, false, { task })
  else
    vim.api.nvim_buf_set_lines(M.tasks_bufnr, -1, -1, false, { task })
  end
  M.strip_blank_tasks()
  M.redraw_winbar()
end

--- Toggle todo winbar
function M.toggle()
  M.enabled = not M.enabled
  M.redraw_winbar()
end

--- Drop current task with no event
function M.drop()
  vim.api.nvim_buf_set_lines(M.tasks_bufnr, 0, 1, false, {})
  M.redraw_winbar()
end

--- Defer current task to end of list
function M.defer()
  local task = M.current_task()
  if task == "" then
    return
  end
  vim.api.nvim_buf_set_lines(M.tasks_bufnr, 0, 1, false, {})
  vim.api.nvim_buf_set_lines(M.tasks_bufnr, -1, -1, false, { task })

  M.redraw_winbar()
end

--- Edit the tasks in a floating window
function M.edit()
  M.open_float()
end

--- Finish the current task
function M.done()
  vim.api.nvim_exec_autocmds("User", { pattern = "doing:Done", data = M.current_task() })
  M.drop()
end

---@return string
function M.current_task()
  if not M.enabled then
    return ""
  end
  local lines = vim.api.nvim_buf_get_lines(M.tasks_bufnr, 0, 1, false)
  return lines[1] or ""
end

---@class (exact) Opts
---@field tasks_file string
---@field ignored_filetypes string[]
---@field winbar boolean
---@field enabled boolean
M.default_opts = {
  enabled = true,
  winbar = true,
  tasks_file = ".tasks",
  ignored_filetypes = {
    "prompt",
    "help",
    "qf",
  },
}
M.augroup = vim.api.nvim_create_augroup("doing", {})

--- Setup M for use in new directory
function M.setup_dir()
  M.tasks_bufnr = vim.fn.bufadd(M.options.tasks_file)
  vim.fn.bufload(M.options.tasks_file)
  M.strip_blank_tasks()
  vim.api.nvim_set_option_value("modified", false, { buf = M.tasks_bufnr })
  M.redraw_winbar()
  --[[
  vim.api.nvim_create_autocmd("BufDelete", {
    group = M.augroup,
    buffer = M.tasks_bufnr,
    callback = M.clear_winbar,
  })
  --]]
end

function M.clear_winbar()
  vim.api.nvim_set_option_value("winbar", "", { win = 0 })
end

--- Redraw winbar based on the first line of the tasks buffer
function M.redraw_winbar()
  if
    not M.enabled
    or not M.winbar
    or vim.fn.win_gettype() ~= ""
    or vim.tbl_contains(M.options.ignored_filetypes, vim.bo.filetype, {})
  then
    vim.api.nvim_set_option_value("winbar", "", { win = 0 })
    return
  end

  local task = M.current_task() or ""
  vim.api.nvim_set_option_value("winbar", task, { win = 0 })
end

function M.open_float()
  local width = math.min(vim.opt.columns:get(), 80)
  local height = math.min(vim.opt.lines:get(), 12)
  local win = vim.api.nvim_open_win(M.tasks_bufnr, true, {
    relative = "editor",
    border = "rounded",
    noautocmd = false,
    col = vim.opt.columns:get() / 2 - width / 2,
    row = vim.opt.lines:get() / 2 - height / 2,
    width = width,
    height = height,
  })

  vim.api.nvim_set_option_value("winhl", "Normal:NormalFloat", {})
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    group = M.augroup,
    callback = function()
      M.strip_blank_tasks()
      M.redraw_winbar()
    end,
  })
end

function M.strip_blank_tasks()
  local tasks = vim.api.nvim_buf_get_lines(M.tasks_bufnr, 0, -1, false)
  local filtered = vim.tbl_filter(function(row)
    return vim.trim(row) ~= ""
  end, tasks)
  vim.api.nvim_buf_set_lines(M.tasks_bufnr, 0, -1, false, filtered)
end

---@param opts Opts
function M.setup(opts)
  local opts = vim.tbl_deep_extend("force", M.default_opts, opts or {})

  M.options = opts
  M.winbar = opts.winbar
  M.setup_dir()

  vim.api.nvim_create_autocmd("DirChanged", {
    group = M.augroup,
    callback = function()
      M.setup_dir()
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
    group = M.augroup,
    callback = M.redraw_winbar,
  })

  vim.api.nvim_create_user_command("Do", function(args)
    M.add(unpack(args.fargs), args.bang)
  end, { nargs = 1, bang = true })

  vim.api.nvim_create_user_command("DoToggle", M.toggle, {})
  vim.api.nvim_create_user_command("Defer", M.defer, {})
  vim.api.nvim_create_user_command("Drop", M.drop, {})
  vim.api.nvim_create_user_command("Done", M.done, {})
  vim.api.nvim_create_user_command("DoEdit", M.edit, {})
end

return M