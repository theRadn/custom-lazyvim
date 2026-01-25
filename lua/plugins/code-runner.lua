return {
  "CRAG666/code_runner.nvim",
  config = true,
  opts = {
    filetype = {
      java = {
        "cd $dir &&",
        "javac $fileName &&",
        "java $fileNameWithoutExt",
      },
      python = "python3 -u",
      typescript = "deno run",
      javascript = "node $fileName",
      rust = {
        "cd $dir &&",
        "rustc $fileName &&",
        "$dir/$fileNameWithoutExt",
      },
      c = "cd $dir && gcc $fileName -g -o $fileNameWithoutExt && ./$fileNameWithoutExt",
      cpp = "cd $dir && g++ $fileName -g -o $fileNameWithoutExt && ./$fileNameWithoutExt",
    },
  },
}
