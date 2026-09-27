return {
  "yetone/avante.nvim",
  build = false, -- bulid manually in ~/.local/share/nvim/lazy/avante.nvim and run make BUILD_FROM_SOURCE=true
  mode = "legacy", -- legacy | agentic
  opts = {
    provider = "celeris",
    providers = {
      mistral = {
        __inherited_from = "openai",
        api_key_name = "MISTRAL_API_KEY",
        endpoint = "https://api.mistral.ai/v1",
        model = "ministral-14b-2512",
      },
      celeris = {
        __inherited_from = "openai",
        endpoint = "https://inference.celeris.ai/celeris-1/v1",
        api_key_name = "CELERIS_API_KEY",
        model = "celeris-1",
        extra_request_body = {
          max_tokens = 8192,
        },
      },
    },
    behaviour = {
      auto_suggestions = false,
      auto_add_current_file = false,
      auto_apply_diff_after_generation = true,
      auto_approve_tool_permissions = false,
      enable_fastapply = false,
    },
    disabled_tools = {
      -- "str_replace",
      -- "create",
      -- "insert",
      -- "write_to_file",
      -- "undo_edit",
      -- "edit_file",
      -- "view",
      -- "bash",
      -- "grep",
      -- "glob",
      -- "get_diagnostics",
    },
  },
}
