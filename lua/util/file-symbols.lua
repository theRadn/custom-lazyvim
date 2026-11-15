local M = {}

local category_order = {
  "CLASSES",
  "STRUCTS",
  "INTERFACES",
  "ENUMS",
  "TYPE ALIASES",
  "CONSTRUCTORS",
  "FUNCTIONS",
  "METHODS",
  "FIELDS",
  "PROPERTIES",
  "CONSTANTS",
  "GLOBAL VARIABLES",
  "NAMESPACES",
  "MODULES",
  "MACROS",
}

local function get_files_from_path(path)
  local fullpath = vim.fn.fnamemodify(path, ":p")
  local stat = vim.uv.fs_stat(fullpath)

  if not stat then
    return {}
  end

  if stat.type == "file" then
    return { fullpath }
  end

  if stat.type ~= "directory" then
    return {}
  end

  local pattern = fullpath:gsub("/+$", "") .. "/**/*"
  local entries = vim.fn.glob(pattern, false, true)
  local files = {}

  for _, entry in ipairs(entries) do
    if vim.fn.filereadable(entry) == 1 then
      table.insert(files, vim.fn.fnamemodify(entry, ":p"))
    end
  end

  return files
end

local function get_selected_path(item)
  return item.file
    or item.path
    or (item.cwd and item.text and (item.cwd .. "/" .. item.text))
    or item.text
end

local function read_file(path)
  local file = io.open(path, "r")

  if not file then
    return nil
  end

  local content = file:read("*a")
  file:close()

  return content
end

local function get_language(path)
  local filetype = vim.filetype.match({ filename = path })

  if not filetype then
    return nil
  end

  return vim.treesitter.language.get_lang(filetype)
end

local function normalize_text(value, max_length)
  value = value:gsub("%s+", " ")
  value = vim.trim(value)

  if #value > max_length then
    value = value:sub(1, max_length - 3) .. "..."
  end

  return value
end

-- Extract common imports/includes without requiring language-specific queries.
local function extract_imports(content)
  local imports = {}
  local seen = {}
  local lines = vim.split(content, "\n", { plain = true })

  local in_go_import = false
  local in_rust_use = false

  local function add(line_number, value)
    value = vim.trim(value)

    if value == "" or seen[value] then
      return
    end

    seen[value] = true

    table.insert(imports, {
      line = line_number,
      value = value,
    })
  end

  for line_number, line in ipairs(lines) do
    local trimmed = vim.trim(line)

    -- Go import blocks.
    if trimmed:match("^import%s*%(") then
      in_go_import = true
    elseif in_go_import then
      if trimmed:match("^%)") then
        in_go_import = false
      elseif not trimmed:match("^//") then
        add(line_number, trimmed)
      end
    elseif trimmed:match("^import%s+") then
      add(line_number, trimmed)

    -- Python imports.
    elseif trimmed:match("^from%s+[%w_%.]+%s+import%s+")
      or trimmed:match("^import%s+[%w_%.]+") then
      add(line_number, trimmed)

    -- JavaScript / TypeScript imports and exports.
    elseif trimmed:match("^import%s+")
      or trimmed:match("^export%s+.*from%s+") then
      add(line_number, trimmed)

    -- Rust use declarations.
    elseif trimmed:match("^use%s+") then
      if trimmed:find(";", 1, true) then
        add(line_number, trimmed)
      else
        in_rust_use = true
        add(line_number, trimmed)
      end
    elseif in_rust_use then
      add(line_number, trimmed)

      if trimmed:find(";", 1, true) then
        in_rust_use = false
      end

    -- C / C++ includes.
    elseif trimmed:match("^#%s*include%s+") then
      add(line_number, trimmed)

    -- C# / Java / PHP.
    elseif trimmed:match("^using%s+[%w_%.]+")
      or trimmed:match("^package%s+[%w_%.]+")
      or trimmed:match("^require%s*%(") then
      add(line_number, trimmed)
    end
  end

  return imports
end

local node_categories = {
  go = {
    function_declaration = "FUNCTIONS",
    method_declaration = "METHODS",
    type_spec = "TYPES",
    struct_type = "STRUCTS",
    interface_type = "INTERFACES",
    const_spec = "CONSTANTS",
    var_spec = "GLOBAL VARIABLES",
    field_declaration = "FIELDS",
  },

  lua = {
    function_declaration = "FUNCTIONS",
    function_definition = "FUNCTIONS",
    variable_declaration = "GLOBAL VARIABLES",
  },

  python = {
    function_definition = "FUNCTIONS",
    class_definition = "CLASSES",
  },

  javascript = {
    function_declaration = "FUNCTIONS",
    class_declaration = "CLASSES",
    method_definition = "METHODS",
    lexical_declaration = "GLOBAL VARIABLES",
    variable_declaration = "GLOBAL VARIABLES",
  },

  typescript = {
    function_declaration = "FUNCTIONS",
    class_declaration = "CLASSES",
    interface_declaration = "INTERFACES",
    type_alias_declaration = "TYPE ALIASES",
    enum_declaration = "ENUMS",
    method_definition = "METHODS",
    public_field_definition = "FIELDS",
    lexical_declaration = "GLOBAL VARIABLES",
  },

  rust = {
    function_item = "FUNCTIONS",
    struct_item = "STRUCTS",
    enum_item = "ENUMS",
    trait_item = "INTERFACES",
    impl_item = "METHODS",
    type_item = "TYPE ALIASES",
    const_item = "CONSTANTS",
    static_item = "GLOBAL VARIABLES",
    macro_definition = "MACROS",
  },

  c = {
    function_definition = "FUNCTIONS",
    struct_specifier = "STRUCTS",
    enum_specifier = "ENUMS",
    type_definition = "TYPE ALIASES",
    declaration = "GLOBAL VARIABLES",
  },

  cpp = {
    function_definition = "FUNCTIONS",
    class_specifier = "CLASSES",
    struct_specifier = "STRUCTS",
    enum_specifier = "ENUMS",
    alias_declaration = "TYPE ALIASES",
    namespace_definition = "NAMESPACES",
  },
}

local function get_node_name(node, source)
  for child in node:iter_children() do
    local child_type = child:type()

    if child_type:find("identifier", 1, true)
      or child_type == "name"
      or child_type == "type_identifier" then
      return vim.treesitter.get_node_text(child, source)
    end
  end

  return vim.treesitter.get_node_text(node, source):match("^[%w_]+")
end

local function extract_symbols(path, content)
  local language = get_language(path)

  if not language then
    return nil, "Unknown language"
  end

  local mapping = node_categories[language]

  if not mapping then
    return nil, "No AST mapping for " .. language
  end

  local ok, parser = pcall(
    vim.treesitter.get_string_parser,
    content,
    language
  )

  if not ok then
    return nil, "Parser unavailable"
  end

  local parsed, trees = pcall(function()
    return parser:parse()
  end)

  if not parsed or not trees or not trees[1] then
    return nil, "Failed to parse file"
  end

  local symbols = {}
  local root = trees[1]:root()

  local function visit(node)
    local category = mapping[node:type()]

    if category then
      symbols[category] = symbols[category] or {}

      local name = get_node_name(node, content)

      if name then
        table.insert(symbols[category], {
          name = name,
          line = node:start() + 1,
          declaration = normalize_text(
            vim.treesitter.get_node_text(node, content):match("^[^\n]*") or "",
            220
          ),
        })
      end
    end

    for child in node:iter_children() do
      visit(child)
    end
  end

  visit(root)

  return symbols
end

local function format_imports(imports)
  if #imports == 0 then
    return nil
  end

  local output = { "IMPORTS:" }

  for _, item in ipairs(imports) do
    table.insert(
      output,
      string.format("  [line %d] %s", item.line, item.value)
    )
  end

  return table.concat(output, "\n")
end

local function format_symbols(symbols)
  local output = {}
  local found = false

  for _, category in ipairs(category_order) do
    local entries = symbols[category]

    if entries and #entries > 0 then
      found = true

      table.sort(entries, function(a, b)
        return a.line < b.line
      end)

      table.insert(output, category .. ":")

      for _, entry in ipairs(entries) do
        local line = string.format(
          "  %s (line %d)",
          entry.name,
          entry.line
        )

        if entry.declaration and entry.declaration ~= entry.name then
          line = line .. "\n    " .. entry.declaration
        end

        table.insert(output, line)
      end
    end
  end

  if not found then
    table.insert(output, "No supported definitions found.")
  end

  return table.concat(output, "\n")
end

local function format_file(path)
  local content = read_file(path)

  if not content then
    vim.notify(
      "Failed to read file: " .. path,
      vim.log.levels.WARN
    )
    return nil
  end

  local symbols, err = extract_symbols(path, content)

  if not symbols then
    vim.notify(
      string.format("%s: %s", path, err),
      vim.log.levels.DEBUG
    )
    return nil
  end

  local output = {
    string.format(
      "--- FILE: %s ---",
      vim.fn.fnamemodify(path, ":.")
    ),
  }

  local imports = extract_imports(content)
  local import_output = format_imports(imports)

  if import_output then
    table.insert(output, import_output)
  end

  table.insert(output, format_symbols(symbols))

  return table.concat(output, "\n\n")
end

function M.format_symbols(selected_items)
  local compiled = {}
  local seen = {}

  for _, item in ipairs(selected_items) do
    local path = get_selected_path(item)

    if path then
      for _, fullpath in ipairs(get_files_from_path(path)) do
        if not seen[fullpath] then
          seen[fullpath] = true

          local result = format_file(fullpath)

          if result then
            table.insert(compiled, result)
          end
        end
      end
    end
  end

  return compiled
end

function M.copy_to_clipboard(compiled)
  if #compiled == 0 then
    vim.notify(
      "No symbols found!",
      vim.log.levels.WARN,
      { title = "Snacks Picker" }
    )
    return false
  end

  local output = table.concat(compiled, "\n\n")

  vim.fn.setreg("+", output)
  vim.fn.setreg("*", output)

  vim.notify(
    string.format(
      "Copied symbol maps from %d file(s)!",
      #compiled
    ),
    vim.log.levels.INFO,
    { title = "Snacks Picker" }
  )

  return true
end

function M.copy_selected_symbols(picker, should_close)
  if type(picker) ~= "table" or not picker.selected then
    local pickers = require("snacks").picker.get()

    picker = vim.iter(pickers):find(function(p)
      return p:is_focused()
    end) or pickers[#pickers]
  end

  if not picker then
    vim.notify(
      "No active picker found!",
      vim.log.levels.WARN,
      { title = "Snacks Picker" }
    )
    return
  end

  local selected = picker:selected()

  if #selected == 0 then
    local current = picker:current()

    if current then
      table.insert(selected, current)
    end
  end

  if #selected == 0 then
    vim.notify(
      "No files selected!",
      vim.log.levels.WARN,
      { title = "Snacks Picker" }
    )
    return
  end

  local compiled = M.format_symbols(selected)

  if #compiled > 0 then
    local success = M.copy_to_clipboard(compiled)

    if success and should_close then
      picker:close()
    end
  end
end

return M

