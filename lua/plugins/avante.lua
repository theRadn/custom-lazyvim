return {
  "yetone/avante.nvim",
  opts = {
    provider = "mistral",
    providers = {
      mistral = {
        __inherited_from = "openai",
        api_key_name = "MISTRAL_API_KEY",
        endpoint = "https://api.mistral.ai/v1",
        model = "ministral-14b-2512",
      },
    },
  },
}
