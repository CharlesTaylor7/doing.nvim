return {
  check = function()
    vim.health.start("foo report")
    -- make sure setup function parameters are ok

    vim.health.ok(vim.inspect(require("doing")))
    --      vim.health.error("Setup is incorrect")
  end,
}
