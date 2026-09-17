_G.fsr = {}

local initializer = require("initializer")

initializer.register({
    {
        event = "PackChanged",
        once = false,
        module_names = {
            "plugin.fff.setup",
        },
    },
})

initializer.require_modules(nil, {
    "tweak.setup",
    "plugin.setup",
    "keymap.setup",
    "appearance.setup",
    "filetype.setup",
})

initializer.register({
    {
        event = "UIEnter",
        module_names = {
            "opt.setup",
            "ssh.setup",
            "appearance.icon.setup",
            "statusline.setup",
            "file_explorer.setup",
            "picker.fff.setup",
            "notification.setup",
            "autocmd.open_quick_fix_list_post_grep.setup",
            "user_command.neovim_open_settings.setup",
            "user_command.vim_pack_remove_inactive.setup",
            "user_command.pick_buffer.setup",
            "which_key.setup",
        },
    },
    {
        event = "LspAttach",
        module_names = {
            "lsp.completion.setup",
            "lsp.diagnostic.setup",
            "lsp.document_highlight.setup",
            "lsp.keymap.setup",
        },
    },
    {
        event = "FileType",
        module_names = {
            "tree_sitter.setup",
            "tree_sitter.mini_ai.setup",
            "lsp.setup",
        },
    },
    {
        event = "FileType",
        pattern = "typst",
        module_names = {
            "ftplugin.typst.setup",
        },
    },
    {
        event = "FileType",
        pattern = { "nu", "nuon" },
        once = false,
        module_names = {
            "ftplugin.nu.editorconfig.setup",
        },
    },
    {
        event = "BufEnter",
        module_names = {
            "formatter.setup",
            "autocmd.highlight_on_yank.setup",
        },
    },
})

initializer.require_modules(nil, {
    "project_settings.setup",
})
