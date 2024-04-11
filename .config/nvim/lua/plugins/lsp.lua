return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "b0o/schemastore.nvim",
        'towolf/vim-helm',
    },
    config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
            callback = function(event)
                local map = function(keys, func, desc)
                    vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                end
                map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                map('K', vim.lsp.buf.hover, 'Hover Documentation')
                map('<leader>vca', vim.lsp.buf.code_action, '[C]ode [A]ction')
                map('<leader>vrr', vim.lsp.buf.references, 'references')
                map('<leader>vrn', vim.lsp.buf.rename, '[R]e[n]ame')
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client.server_capabilities.documentHighlightProvider then
                    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                        buffer = event.buf,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                        buffer = event.buf,
                        callback = vim.lsp.buf.clear_references,
                    })
                end
            end
        })

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

        local servers = {
            lua_ls = {},
            helm_ls = {},
            yamlls = {},
            tsserver = {}
        }

        require("mason").setup()

        local ensure_installed = vim.tbl_keys(servers or {})

        require("mason-lspconfig").setup({
            ensure_installed = ensure_installed,
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,
                ["helm_ls"] = function()
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
                ["jsonls"] = function()
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
                                    ["https://json.schemastore.org/kustomization.json"] = "kustomization.{yml,yaml}",
                                    ["https://json.schemastore.org/helmfile.json"] = "helmfile.{yml,yaml}",
                                    ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/*docker-compose*.{yml,yaml}",
                                    ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = "*gitlab-ci*.{yml,yaml}",
                                    ["https://json.schemastore.org/chart.json"] = "Chart.{yml,yaml}",
                                    kubernetes = "/*.yaml"
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
