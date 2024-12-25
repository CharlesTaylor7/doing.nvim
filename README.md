# Doing.nvim

A tiny task manager within nvim that helps you stay on track.

This plugin was originally a fork of [Hashino/doing.nvim](https://github.com/Hashino/doing.nvim)
which itself was originally a fork of [nocksock/do.nvim](https://github.com/nocksock/do.nvim)

## Usage

-  `:Do` append a task to the end of the task buffer
-  `:Do!` prepend a task to the front of task buffer
-  `:Done` complete task 
-  `:DoEdit` edit task buffer in a floating window

## Configuration

``` lua
-- example configuration
return {
  "CharlesTaylor7/doing.nvim",
  opt = {
    tasks_file = ".tasks",
  },
}
```
