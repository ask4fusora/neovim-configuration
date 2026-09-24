local M = {}

local DEFAULT_WIDTH = 60
local MAX_HEIGHT = 15

local api = vim.api

local bufnrs = {} ---@type integer[]
local is_picker_open = false

---@return integer[]
local function listed_bufnrs()
    return vim.iter(vim.fn.getbufinfo({ buflisted = 1 }))
        :map(function(buf)
            return buf.bufnr
        end)
        :totable()
end

---@return string[]
local function buffer_names()
    return vim.tbl_map(function(bufnr)
        local buf_name = api.nvim_buf_get_name(bufnr)

        if vim.bo[bufnr].buftype == "quickfix" then
            local winid = vim.fn.bufwinid(bufnr)
            local buftype = vim.api.nvim_eval_statusline("%q", {
                winid = winid,
            }).str
            local title = vim.w[winid].quickfix_title ---@type string

            buf_name = ("%s %s"):format(buftype, title)
        elseif buf_name == "" then
            buf_name = "untitled"
        else
            buf_name = vim.fn.fnamemodify(buf_name, ":~:.")
        end

        local modified_marker = vim.bo[bufnr].modified and "[+]" or ""

        return ("%s %s"):format(buf_name, modified_marker)
    end, bufnrs)
end

---@return integer bufnr
local function create_picker_buffer()
    local bufnr = api.nvim_create_buf(false, true)

    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].bufhidden = "wipe"

    return bufnr
end

---@param bufnr integer
---@param lines string[]
local function set_buffer_lines(bufnr, lines)
    vim.bo[bufnr].modifiable = true
    api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.bo[bufnr].modifiable = false
end

---@param lines string[]
---@return integer width
---@return integer height
local function picker_dimensions(lines)
    local height = math.min(#lines, MAX_HEIGHT)
    local width = vim.iter(lines)
        :fold(DEFAULT_WIDTH, function(current_max_width, l)
            return math.max(current_max_width, vim.fn.strdisplaywidth(l))
        end)

    -- Ensure width does not exceed horizontal viewport.
    width = math.min(
        width + vim.o.sidescrolloff * 2,
        vim.o.columns - vim.o.sidescrolloff * 2
    )

    return width, height
end

---@class fsr.picker.buffer.open_picker_win.InitOpts
---@field width integer
---@field height integer

---@param picker_bufnr integer
---@param init_opts fsr.picker.buffer.open_picker_win.InitOpts
local function open_picker_win(picker_bufnr, init_opts)
    local invocation_bufnr = api.nvim_get_current_buf()
    ---@type integer|nil
    local initial_cursor_line = vim.iter(ipairs(bufnrs)):find(function(_, b)
        return b == invocation_bufnr
    end)

    local winid = api.nvim_open_win(picker_bufnr, true, {
        style = "minimal",
        title = " Buffers ",
        title_pos = "left",

        -- Initialization options required by neovim.
        relative = "editor",
        row = math.floor((vim.o.lines - init_opts.height) / 2),
        col = math.floor((vim.o.columns - init_opts.width) / 2),
        width = init_opts.width,
        height = init_opts.height,
    })

    is_picker_open = true

    api.nvim_win_set_cursor(winid, { initial_cursor_line or 1, 0 })

    vim.wo[winid].cursorline = true
    vim.wo[winid].wrap = false

    return winid
end

---@param winid integer
---@param width integer
---@param height integer Must be greater than 0.
local function set_picker_win_bounds(winid, width, height)
    assert(height > 0, "`height` of picker must be greater than 0.")
    api.nvim_win_set_config(winid, {
        relative = "editor",
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
    })
end

---@param winid integer
local function close_picker(winid)
    if api.nvim_win_is_valid(winid) then
        api.nvim_win_close(winid, true)
        is_picker_open = false
    end
end

---@param picker_winid integer
local function open_buffer(picker_winid)
    local index = unpack(api.nvim_win_get_cursor(picker_winid))
    local selected_bufnr = bufnrs[index]

    close_picker(picker_winid)

    if selected_bufnr and api.nvim_buf_is_valid(selected_bufnr) then
        api.nvim_set_current_buf(selected_bufnr)
    end
end

---@param winid integer
---@param bufnr integer
local function update_picker(winid, bufnr)
    bufnrs = listed_bufnrs()
    if #bufnrs == 0 then
        return close_picker(winid)
    end

    local lines = buffer_names()
    set_buffer_lines(bufnr, lines)
    local width, height = picker_dimensions(lines)
    assert(height > 0, "`height` should be greater than 0.")
    set_picker_win_bounds(winid, width, height)
end

---@param invocation_winid integer
---@param picker_winid integer
---@param picker_bufnr integer
local function close_buffer(invocation_winid, picker_winid, picker_bufnr)
    local index = unpack(api.nvim_win_get_cursor(picker_winid))
    local selected_bufnr = bufnrs[index]

    local success = pcall(api.nvim_win_call, invocation_winid, function()
        api.nvim_buf_delete(selected_bufnr, { force = false })
    end)

    if not success then
        vim.notify(
            "Cannot close buffer unsaved since last change.",
            vim.log.levels.ERROR
        )
        return
    end

    update_picker(picker_winid, picker_bufnr)
end

---@param invocation_winid integer
---@param picker_winid integer
---@param picker_bufnr integer
local function set_picker_keymaps(invocation_winid, picker_winid, picker_bufnr)
    vim.keymap.set("n", "<CR>", function()
        open_buffer(picker_winid)
    end, {
        buffer = picker_bufnr,
        nowait = true,
    })

    vim.keymap.set("n", "q", function()
        close_picker(picker_winid)
    end, {
        buffer = picker_bufnr,
        nowait = true,
    })

    vim.keymap.set("n", "<Esc>", function()
        close_picker(picker_winid)
    end, {
        buffer = picker_bufnr,
        nowait = true,
    })

    vim.keymap.set("n", "dd", function()
        close_buffer(invocation_winid, picker_winid, picker_bufnr)
    end, {
        buffer = picker_bufnr,
        nowait = true,
        desc = "Close selected buffer",
    })

    vim.keymap.set("n", "<C-s>", function()
        vim.cmd.wa()
    end, {
        buffer = picker_bufnr,
        nowait = true,
    })
end

---@param picker_winid integer
---@param picker_bufnr integer
local function set_picker_autocmd(picker_winid, picker_bufnr)
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup(
            "fsr.picker.buffer.UpdatePicker",
            { clear = true }
        ),
        callback = function()
            if not is_picker_open then
                return
            end

            update_picker(picker_winid, picker_bufnr)
        end,
    })
end

function M.open()
    bufnrs = listed_bufnrs()
    if #bufnrs == 0 then
        return
    end

    local invocation_winid = api.nvim_get_current_win()

    local lines = buffer_names()
    local picker_bufnr = create_picker_buffer()
    set_buffer_lines(picker_bufnr, lines)
    local width, height = picker_dimensions(lines)
    local picker_winid = open_picker_win(picker_bufnr, {
        width = width,
        height = height,
    })

    set_picker_keymaps(invocation_winid, picker_winid, picker_bufnr)
    set_picker_autocmd(picker_winid, picker_bufnr)
end

return M
