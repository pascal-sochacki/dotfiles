return {
    'stevearc/conform.nvim',
    opts = {
        notify_on_error = true,
        format_on_save = {
            timeout_ms = 5000,
            lsp_fallback = true,
        },
        formatters_by_ft = {
            lua = { 'stylua' },
            go = { 'gofmt' },
            -- Conform can also run multiple formatters sequentially
            -- python = { "isort", "black" },
            --
            -- You can use a sub-list to tell conform to run *until* a formatter
            -- is found.
            javascript = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            json = { "prettier" },
            typescript = { "prettier" },
            typescriptreact = { "prettier" },
        },
    },
}
