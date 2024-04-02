return {
    "David-Kunz/gen.nvim",
    opts = {
        model = "mistral",      -- The default model to use.
        display_mode = "split", -- The display mode. Can be "float" or "split".
        show_prompt = false,    -- Shows the prompt submitted to Ollama.
        show_model = false,     -- Displays which model you are using at the beginning of your chat session.
        no_auto_close = false,  -- Never closes the window automatically.
        debug = false           -- Prints errors and the command which is run.
    }
}
