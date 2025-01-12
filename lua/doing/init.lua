--- A tinier task manager that helps you stay on track.
local M = {}

--- Add a task to the list
function M.add(task)
  vim.api.nvim_buf_set_lines(M.tasks_bufnr, 0, 0, false, { task })
  M.strip_blank_tasks()
end

--- Finish the current task
function M.done()
  vim.api.nvim_exec_autocmds("User", { pattern = "doing:Done", data = M.current_task() })
  M.drop()
end

--- Drop current task with no event
function M.drop()
  vim.api.nvim_buf_set_lines(M.tasks_bufnr, 0, 1, false, {})
end

--- Edit the tasks in a floating window
function M.edit()
  M.open_float()
end

---@return string
function M.current_task()
  local lines = vim.api.nvim_buf_get_lines(M.tasks_bufnr, 0, 1, false)
  return lines[1] or ""
end

---@class (exact) Opts
---@field tasks_file string
---@field ignored_filetypes string[]
M.default_opts = {
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
  vim.api.nvim_set_option_value("buflisted", false, { buf = M.tasks_bufnr })
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
    callback = M.strip_blank_tasks,
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
  M.setup_dir()

  vim.api.nvim_create_autocmd("DirChanged", {
    group = M.augroup,
    callback = M.setup_dir,
  })

  vim.api.nvim_create_user_command("Do", function(args)
    M.add(table.unpack(args.fargs))
  end, { nargs = 1 })

  vim.api.nvim_create_user_command("Drop", M.drop, {})
  vim.api.nvim_create_user_command("Done", M.done, {})
  vim.api.nvim_create_user_command("DoEdit", M.edit, {})
end

return M
