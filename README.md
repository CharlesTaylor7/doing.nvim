# Doing.nvim

A tiny task manager within nvim that helps you stay on track.

This plugin was originally a fork of [Hashino/doing.nvim](https://github.com/Hashino/doing.nvim)
which itself was originally a fork of [nocksock/do.nvim](https://github.com/nocksock/do.nvim)

## Usage

- `:Do` append a task to the end of the task buffer
- `:Do!` prepend a task to the front of task buffer
- `:Done` complete task and emit a custom event 
- `:Drop` drop task from front of list with no event
- `:Defer` move task from front to back of list
- `:DoEdit` edit task buffer in a floating window

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
