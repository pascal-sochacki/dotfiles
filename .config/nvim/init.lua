vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.keymap.set("n", "<F2>", vim.diagnostic.goto_next)

vim.opt.colorcolumn = "80"

local augroup = vim.api.nvim_create_augroup
local pascal = augroup('pascal', {})
local autocmd = vim.api.nvim_create_autocmd

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd({ 'BufNewFile', 'BufRead' }, {
    group = pascal,
    pattern = { '*/templates/*.yaml' },
    callback = function()
        vim.opt_local.filetype = 'helm'
    end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")


local yank_group = augroup('HighlightYank', {})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 300,
        })
    end,
})
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)


local attach_to_buffer = function(output_bufnr, command, pattern)
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = vim.api.nvim_create_augroup("pascal-autorun", { clear = true }),
        pattern = pattern,
        callback = function()
            local append_data = function(_, data)
                if data then
                    vim.api.nvim_buf_set_lines(output_bufnr, -1, -1, false, data)
                end
            end

            vim.api.nvim_buf_set_lines(output_bufnr, 0, -1, false, { "auto run output:" })
            vim.fn.jobstart(command, {
                stdout_buffered = true,
                on_stdout = append_data,
                on_stderr = append_data,
            })
        end

    })
end

vim.api.nvim_create_user_command("AutoRun", function()
    vim.cmd('vnew')

    local bufnr = vim.api.nvim_get_current_buf()
    local command = vim.split(vim.fn.input("Command: "), " ")
    local pattern = vim.fn.input("Pattern: ")

    attach_to_buffer(bufnr, command, pattern)
end, {})

vim.api.nvim_create_user_command("PwGen", function()
    local char = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#"

    local password = ""
    for i = 1, vim.fn.input("Length: ") do
        local index = math.random(1, #char)
        password = password .. string.sub(char, index, index)
    end
    vim.api.nvim_feedkeys("i", 'm', true)
    vim.api.nvim_feedkeys(password, 'm', true)
end, {})


local function get_keys(root)
    local keys = {}
    for node, name in root:iter_children() do
        if name == "key" then
            table.insert(keys, node)
        end

        if node:child_count() > 0 then
            for _, child in pairs(get_keys(node)) do
                table.insert(keys, child)
            end
        end
    end
    return keys
end

vim.api.nvim_create_user_command("YAMLPaste", function()
    local reg = vim.fn.getreg('"')
    local key, value = reg:match("(%a[%w%.]*)%s*=%s*\"?([^\"]+)\"?")

    if key == nil or value == nil then
        print("could not match key and value...")
        return
    end

    vim.fn.jobstart("", {
        stdout_buffered = true,
    })
    local cmd = string.format("!yq '.%s = \"%s\"' -i %s", key, value, "%")
    vim.cmd(cmd)
end, {})

vim.api.nvim_create_user_command("YAMLSort", function()
    local cmd = string.format("!yq -i -P 'sort_keys(..)' %s", "%")
    vim.cmd(cmd)
end, {})
