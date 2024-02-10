local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
  'tsserver',
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()


local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

vim.keymap.set("n", "<F2>", vim.diagnostic.goto_next)

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})



local ls = require("luasnip")
require("luasnip.loaders.from_vscode").load()

local snip = ls.snippet
local func = ls.function_node

local same = function (index)
    return func(function (arg)
       return arg[1]
    end, { index })
end

ls.add_snippets(nil, {
    go = {
        snip({
            trig = "ennn",
            namr = "error not nil",
            dscr = "check if error is not nil",
        }, {
            ls.insert_node(1, { "val" }),
            ls.text_node(", "),
            ls.insert_node(2, { "err" }),
            ls.text_node(" := "),
            ls.insert_node(3, { "f" }),
            ls.text_node("("),
            ls.insert_node(4),
            ls.text_node(")"),
            ls.text_node({"", "if "}),
            same(2),
            ls.text_node(" != nil {", "\treturn ")
        }),
    }
})

ls.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI"
})


vim.keymap.set({"i", "s"}, "<c-k>", function ()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
 end, {silent = true})

vim.keymap.set({"i", "s"}, "<c-j>", function ()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end, {silent = true})

vim.keymap.set({"i"}, "<c-l>", function ()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end)






lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)
lsp.format_on_save({
  format_opts = {
    async = false,
    timeout_ms = 10000,
  },
  servers = {
      ['null-ls'] = {'go', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'yaml'},
  }
})
lsp.setup()




vim.diagnostic.config({
    virtual_text = true
})

