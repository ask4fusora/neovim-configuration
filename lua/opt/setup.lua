-- Winborder.

vim.o.winborder = "single"
vim.o.pumborder = "single"

-- Gutter.

vim.o.number = true
vim.o.relativenumber = true
vim.o.numberwidth = 5
vim.o.statuscolumn = " %s%=%{v:relnum ? v:relnum : v:lnum} "
vim.o.signcolumn = "yes:1"
vim.o.cursorline = true
-- NOTE: Setting `guicursor` is critical. Without it, the cursor will be
-- inherited from the terminal solely.
vim.o.guicursor = table.concat({ vim.o.guicursor, "a:Cursor" }, ",")
vim.o.fillchars = table.concat({ "eob: " }, ",")

-- Indentation.

vim.o.autoindent = true
vim.o.smartindent = true

-- Is filename.

vim.o.shellslash = true
vim.o.isfname = table.concat({ vim.o.isfname, "(", ")" }, ",")

-- List chars.

vim.o.list = true
vim.o.listchars = table.concat({
    "eol:",
    "tab:→ ",
    "trail:•",
    "nbsp: ",
}, ",")

-- Wrap.

vim.o.wrap = false

-- Neovim.

vim.o.undofile = true
vim.o.autoread = true

-- Providers.

vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Scrolloff.

vim.o.scrolloff = 4
vim.o.sidescrolloff = 8

-- Search features.

vim.o.incsearch = true
vim.o.smartcase = true

-- Completion.

vim.o.autocomplete = false
vim.o.completeopt = "fuzzy,menuone,noselect"

-- Vim mode.
vim.o.showmode = false
