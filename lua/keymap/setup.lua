local keymap = require("keymap")

vim.g.mapleader = " "

keymap.set_cabbrev("grep", "silent grep!")

keymap.set_cabbrev("ls", "PickBuffer")

vim.keymap.set({ "n", "v" }, "<C-s>", function()
    vim.cmd("silent w")
end)

vim.keymap.set("n", "<M-F>", function()
    local formatters = fsr.formatter.formatters_by_filetype[vim.bo.filetype]
    require("formatter").format(formatters)
end, { desc = "Format document" })

vim.keymap.set("v", "<C-k><C-f>", function()
    local formatters = fsr.formatter.formatters_by_filetype[vim.bo.filetype]
    require("formatter").format(formatters)
end, { desc = "Format selections" })

vim.keymap.set(
    "",
    "<leader>s",
    "<Plug>Sneak_s",
    { remap = true, desc = "Sneak forward" }
)

vim.keymap.set(
    "",
    "<leader>S",
    "<Plug>Sneak_S",
    { remap = true, desc = "Sneak backward" }
)
