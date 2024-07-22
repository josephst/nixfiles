-- enable experimental lua loader
vim.loader.enable()

vim.cmd.colorscheme "catppuccin"

-- mini.nvim modules
require('mini.files').setup()