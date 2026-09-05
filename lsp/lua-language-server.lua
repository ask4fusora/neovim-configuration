local root_markers_1 = {
    ".luarc.json",
    ".luarc.jsonc",
}

local root_markers_2 = {
    ".luacheckrc",
    ".stylua.toml",
    "stylua.toml",
    "selene.toml",
    "selene.yml",
}

local root_markers = {
    root_markers_1,
    root_markers_2,
    { ".git" },
}

---Project settings folder name.
local dotnvim = require("project_settings").PROJECT_SETTINGS_FOLDER_NAME

local function is_in_dotnvim(path)
    return require("util.path").contains_folder(path, dotnvim)
end

local function is_in_config_stdpath(path)
    return require("util.string").starts_with(path, vim.fn.stdpath("config"))
end

---@param params lsp.InitializeParams
---@return string|nil root_dir Root directory path in absolute format if there is,
---otherwise `nil`.
local function root_directory(params)
    if type(params.rootUri) == "string" then
        return vim.fs.abspath(vim.uri_to_fname(params.rootUri --[[@as string]]))
    end

    if type(params.rootPath) == "string" then
        return vim.fs.abspath(params.rootPath --[[@as string]])
    end

    return nil
end

---@param should_include_config_stdpath_lib boolean
local function neovim_libraries(should_include_config_stdpath_lib)
    local vimruntime = vim.env.VIMRUNTIME
    -- See :help $VIMRUNTIME.
    assert(type(vimruntime) == "string", "`$VIMRUNTIME` should be a string.")
    ---@cast vimruntime string

    ---@type string[]
    local libraries = {
        vimruntime,
        -- Plugin directory. See :e $VIMRUNTIME/lua/vim/pack/health.lua.
        vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt"),
    }

    -- In case dotnvim user wants to use what they defined in their user config.
    if should_include_config_stdpath_lib then
        table.insert(libraries, vim.fn.stdpath("config"))
    end

    return libraries
end

---@type vim.lsp.Config
return {
    cmd = { "lua-language-server" },

    filetypes = { "lua" },

    settings = {
        -- See https://luals.github.io/wiki/settings.
        Lua = {
            workspace = {
                -- We would not want our project settings to mess things up in a
                -- Lua project.
                ignoreDir = { dotnvim },
            },
        },
    },

    root_dir = function(bufnr, on_dir)
        local buffer_path = vim.api.nvim_buf_get_name(bufnr)

        if is_in_dotnvim(buffer_path) then
            local dotnvim_root_dir = vim.fs.root(bufnr, { dotnvim })
            -- `is_in_dotnvim` meaning the directory containing it
            -- must exist.
            assert(
                type(dotnvim_root_dir) == "string",
                "Expected `dotnvim_root_dir` to be a string."
            )
            ---@cast dotnvim_root_dir string

            return on_dir(vim.fs.joinpath(dotnvim_root_dir, dotnvim))
        end

        if is_in_config_stdpath(buffer_path) then
            return on_dir(vim.fn.stdpath("config"))
        end

        return on_dir(vim.fs.root(bufnr, root_markers))
    end,

    before_init = function(params, config)
        local root_dir = root_directory(params)
        if root_dir == nil then
            return
        end

        local is_root_in_config_stdpath = is_in_config_stdpath(root_dir)
        local is_root_in_dotnvim = is_in_dotnvim(root_dir)
        if not is_root_in_config_stdpath and not is_root_in_dotnvim then
            return
        end

        assert(
            type(config.settings.Lua) == "table",
            "`config.settings.Lua` must be a table."
        )

        config.settings.Lua =
            vim.tbl_deep_extend("force", config.settings.Lua --[[@as table]], {
                runtime = {
                    -- See :help lua-compat.
                    -- See :help lua-luajit.
                    -- See https://luals.github.io/wiki/settings/#runtimeversion.
                    version = jit and "LuaJIT" or "Lua 5.1",
                    -- Mirrors Neovim's Lua module lookup under each runtime path:
                    -- `require("foo.bar")` searches `lua/foo/bar.lua`, then
                    -- `lua/foo/bar/init.lua`.
                    -- See :help lua-module-load.
                    -- `?` is module placeholder. Dots (`.`) are converted to
                    -- directory separators.
                    -- See :help package.path.
                    pathStrict = true,
                    path = {
                        "lua/?.lua",
                        "lua/?/init.lua",
                    },
                },
                workspace = {
                    library = neovim_libraries(is_root_in_dotnvim),
                },
            })
    end,
}
