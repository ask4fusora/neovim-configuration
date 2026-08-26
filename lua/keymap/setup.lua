vim.g.mapleader = " "

vim.keymap.set("ca", "grep", "silent grep!")

vim.keymap.set("ca", "ls", "PickBuffer")

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
