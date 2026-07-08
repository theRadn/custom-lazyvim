return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    enabled = false,
    latex = {
      enabled = true,
      converter = { 'utftex', 'latex2text' },
      highlight = "RenderMarkdownMath",
    },
  },
}
