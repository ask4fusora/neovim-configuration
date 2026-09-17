---@type fsr.initializer.Module
return {
    exec = function(args)
        vim.bo[args.buf].et = true
        vim.bo[args.buf].shiftwidth = 0
        vim.bo[args.buf].tabstop = 4
    end,
}
