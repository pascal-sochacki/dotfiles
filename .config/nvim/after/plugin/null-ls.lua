local null_ls = require("null-ls")


null_ls.setup({
    sources = {
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.terraform_fmt,
        null_ls.builtins.diagnostics.hadolint,
        null_ls.builtins.code_actions.impl
    },
})
