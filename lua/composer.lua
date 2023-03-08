local composer = {}

local function resolve_psr4(directory, map)
  for k, v in pairs(map) do
    if string.sub(directory, 1, string.len(v)) == v then
      return k .. string.sub(directory, string.len(v) + 1):gsub("/", "\\")
    elseif string.sub(directory, 1, string.len(v)) == string.sub(v, 1, -2) then
      return string.sub(k, 1, -2)
    end
  end
end

function composer.read_composer_file()
  local filename = vim.fn.findfile("composer.json", ".;")
  if filename == "" then
    return
  end
  local content = vim.fn.readfile(filename)

  return vim.fn.json_decode(content)
end

function composer.resolve_php_namespace()
  local composer_data = composer.read_composer_file()

  if composer_data == nil or composer_data["autoload"] == nil then
    return nil
  end

  local buffer_directory = vim.fn.expand("%:h")
  local autoload = composer_data["autoload"]

  if autoload["psr-4"] ~= nil then
    local namespace = resolve_psr4(buffer_directory, autoload["psr-4"])
    if namespace ~= nil then
      return namespace
    end
  end

  if autoload["classmap"] ~= nil then
    local classmap = autoload["classmap"]
    for _, v in ipairs(classmap) do
      local fullpath = buffer_directory .. "/" .. v
      if vim.loop.fs_stat(fullpath) ~= nil then
        local namespace = string.sub(fullpath, string.len(vim.loop.cwd()) + 2):gsub("/", "\\"):gsub(".php$", "")
        return namespace
      end
    end
  end

  -- Check if the namespace is defined in the autoload-dev section
  if composer_data["autoload-dev"] ~= nil and composer_data["autoload-dev"]["psr-4"] ~= nil then
    local namespace = resolve_psr4(buffer_directory, composer_data["autoload-dev"]["psr-4"])
    if namespace ~= nil then
      return namespace
    end
  end

  if composer_data["autoload-dev"] ~= nil and composer_data["autoload-dev"]["classmap"] ~= nil then
    local classmap_dev = composer_data["autoload-dev"]["classmap"]
    for _, v in ipairs(classmap_dev) do
      local fullpath = buffer_directory .. "/" .. v
      if vim.loop.fs_stat(fullpath) ~= nil then
        local namespace = string.sub(fullpath, string.len(vim.loop.cwd()) + 2):gsub("/", "\\"):gsub(".php$", "")
        return namespace
      end
    end
  end

  return nil
end

function composer.query_composer_file(keys)
  local composer_data = composer.read_composer_file()

  if composer_data == nil then
    return nil
  end

  local result = composer_data

  for _, key in ipairs(keys) do
    result = result[key]

    if result == nil then
      return nil
    end
  end

  return result
end

return composer
