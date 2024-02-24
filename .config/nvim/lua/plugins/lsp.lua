return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "b0o/schemastore.nvim",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        'towolf/vim-helm',
        "neovim/nvim-lspconfig",
        "rafamadriz/friendly-snippets",
        "j-hui/fidget.nvim",
    },
    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        local luasnip = require("luasnip")
        luasnip.config.set_config({
            history = true,
            updateevents = "TextChanged,TextChangedI"
        })

        vim.keymap.set({"i", "s"}, "<c-k>", function ()
            if luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            end
        end, {silent = true})

        vim.keymap.set({"i", "s"}, "<c-j>", function ()
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            end
        end, {silent = true})

        require("luasnip.loaders.from_vscode").lazy_load()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "helm-ls",
                "yamlls",
                "tsserver",
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,
                ["helm_ls"] = function ()
                    local lspconfig = require('lspconfig')
                    lspconfig.helm_ls.setup {
                        settings = {
                            ['helm-ls'] = {
                                yamlls = {
                                    path = "yaml-language-server",
                                }
                            }
                        }
                    }

                end,
                ["jsonls"] = function ()
                    local lspconfig = require("lspconfig")
                    lspconfig.jsonls.setup {
                        settings = {
                            json = {
                                schemas = require('schemastore').json.schemas(),
                                validate = { enable = true },
                            }
                        }
                    }
                end,
                ["yamlls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.yamlls.setup {
                        settings = {
                            capabilities = capabilities,
                            format = {
                                enable = true,
                                singleQuote = false,
                                bracketSpacing = true
                            },
                            validate = true,
                            completion = true,
                            hover = true,
                            yaml = {
                                schemaStore = {
                                    enable = false,
                                    url = ""
                                },
                                schemas = {
                                    ["https://json.schemastore.org/kustomization.json"] = { "kustomization.{yml,yaml}" },
                                    ["../values.schema.json"] = { "*values*.{yml,yaml}" },
                                    ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = { "docker-compose.{yml,yaml}" },
                                    ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = { "*gitlab-ci*.{yml,yaml}" },
                                    kubernetes = { "/*.yaml" }
                                }
                            }
                        }
                    }
                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,

                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end
            }
        })
        local cmp_select = { behavior = cmp.SelectBehavior.Select }
        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
                { name = 'buffer' },
                { name = "path" },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end

}
