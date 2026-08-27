vim.ui.open = require("tweak").nu_start

-- Enable the cache loader. Neovim will load much faster after first launch.

vim.loader.enable()

-- Enable Neovim ui2. Neovim will be less intrusive.

require("vim._core.ui2").enable()
