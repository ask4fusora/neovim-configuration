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

---Project settings folder name.
local dotnvim = require("project_settings").PROJECT_SETTINGS_FOLDER_NAME

---@type vim.lsp.Config
return {
    cmd = { "lua-language-server" },

    filetypes = { "lua" },

    settings = {
        Lua = {
            workspace = {
                -- We would not want our project settings to mess things up in a
                -- Lua project.
                ignoreDir = { dotnvim },
            },
        },
    },

    root_dir = function(bufnr, on_dir)
        local searchexpr = ("/%s/"):format(dotnvim)
        local buffer_path = vim.api.nvim_buf_get_name(bufnr)
        local is_in_project_settings_dir = buffer_path:find(searchexpr, 1, true)

        if is_in_project_settings_dir then
            local cwd = vim.fs.root(bufnr, { dotnvim })
            -- `is_in_project_settings_dir` meaning the directory containing it
            -- must exist.
            assert(type(cwd) == "string", "Expected `cwd` to be a string.")
            ---@cast cwd string

            return on_dir(vim.fs.joinpath(cwd, dotnvim))
        end

        local user_settings_dir = vim.fn.stdpath("config")
        local is_in_user_settings_dir =
            require("lua.string").starts_with(buffer_path, user_settings_dir)

        if is_in_user_settings_dir then
            return on_dir(user_settings_dir)
        end

        local root_dir = vim.fs.root(bufnr, {
            root_markers_1,
            root_markers_2,
            { ".git" },
        })

        return on_dir(root_dir)
    end,

    before_init = function(params, config)
        ---@type string|nil
        local abs_root_uri = type(params.rootUri) ~= "string" and nil
            or vim.fs.abspath(vim.uri_to_fname(params.rootUri --[[@as string]]))
        ---@type string|nil
        local abs_root_path = type(params.rootPath) ~= "string" and nil
            or vim.fs.abspath(params.rootPath --[[@as string]])
        local root_dir = abs_root_uri or abs_root_path
        if root_dir == nil then
            return
        end

        ---Project settings folder name.
        local searchexpr = ("/%s/"):format(dotnvim)
        local is_in_project_settings_dir = root_dir:find(searchexpr, 1, true)
        local is_in_user_settings_dir = require("lua.string").starts_with(
            root_dir,
            vim.fn.stdpath("config")
        )

        if not is_in_user_settings_dir and not is_in_project_settings_dir then
            return
        end

        local lua_ls_settings = config.settings.Lua
        if type(lua_ls_settings) ~= "table" then
            return
        end

        local vimruntime_dir = vim.env.VIMRUNTIME
        assert(
            type(vimruntime_dir) == "string",
            "`$VIMRUNTIME` should be a string."
        )
        ---@cast vimruntime_dir string

        local libraries = {
            vim.fs.joinpath(vimruntime_dir, "lua"),
            vim.fs.joinpath(
                vim.fn.stdpath("data"),
                "site",
                "pack",
                "core",
                "opt"
            ),
        }

        if is_in_project_settings_dir then
            table.insert(libraries, vim.fn.stdpath("config"))
        end

        config.settings.Lua = vim.tbl_deep_extend("force", lua_ls_settings, {
            runtime = {
                version = "LuaJIT",
                path = {
                    "lua/?.lua",
                    "lua/?/init.lua",
                },
            },
            workspace = {
                library = libraries,
            },
        })
    end,
}
