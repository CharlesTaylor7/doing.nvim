--- A tinier task manager that helps you stay on track.
local M = {}

--- Add a task to the list
function M.add(task, to_front)
  vim.api.nvim_buf_set_lines(M.tasks_bufnr, 0, 0, false, { task })
  M.redraw_winbar()
end

--- M the tasks in a floating window
function M.edit()
  M.open_float()
end

--- Finish the current task
function M.done()
  vim.api.nvim_buf_set_lines(M.tasks_bufnr, 0, 1, false, {})
  M.redraw_winbar()
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

---configure displaying current to do item in winbar
---@param opts Opts
function M.setup(opts)
  M.options = opts
  M.tasks_bufnr = vim.fn.bufadd(opts.tasks_file)
  vim.fn.bufload(opts.tasks_file)

  M.redraw_winbar()

  vim.api.nvim_create_autocmd("BufDelete", {
    group = M.augroup,
    buffer = M.tasks_bufnr,
    callback = M.clear_winbar,
  })
  vim.api.nvim_create_autocmd("DirChanged", {
    group = M.augroup,
    callback = function()
      M.setup(opts)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
    group = M.augroup,
    callback = M.redraw_winbar,
  })
end

function M.clear_winbar()
  vim.api.nvim_set_option_value("winbar", nil, { win = 0 })
end

--- Redraw winbar based on the first line of the tasks buffer
function M.redraw_winbar()
  if vim.tbl_contains(M.options.ignored_filetypes, vim.bo.filetype, {}) then
    M.clear_winbar()
    return
  end

  local lines = vim.api.nvim_buf_get_lines(M.tasks_bufnr, 0, 1, false)
  vim.api.nvim_set_option_value("winbar", lines[1], { win = 0 })
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

  return win
end

return {
  setup = function(opts)
    local plugin = M
    local opts = vim.tbl_deep_extend("force", M.default_opts, opts or {})

    vim.api.nvim_create_user_command("Do", function(args)
      plugin.add(unpack(args.fargs), args.bang)
    end, { nargs = 1, bang = true })

    vim.api.nvim_create_user_command("Done", plugin.done, {})
    vim.api.nvim_create_user_command("DoEdit", plugin.edit, {})

    plugin.setup(opts)
  end,
}
