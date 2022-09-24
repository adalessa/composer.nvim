local M = {}

local function starts_with(text, start)
	return string.sub(text, 1, string.len(start)) == start
end

local function get_composer_file()
    if vim.fn.findfile("composer.json") ~= "" then
        return vim.fn.json_decode(vim.fn.readfile(vim.fn.getcwd() .. "/composer.json"))
    end

    if vim.fn.findfile("master/composer.json") ~= "" then
        return vim.fn.json_decode(vim.fn.readfile(vim.fn.getcwd() .. "/master/composer.json"))
    end

    return nil
end

M.query = function (path)
    local target = get_composer_file()

    if target == nil then
        return nil
    end

    for _, part in ipairs(path) do
        target = target[part]
        if target == nil then
            return nil
        end
    end

    return target
end

M.namespace = function ()
	local dir = vim.fn.expand("%:h")
	local autoloads = M.query({ "autoload", "psr-4" })
	if autoloads == nil then
		return (dir:gsub("^%l", string.upper))
	end

	local globalNamespace
	for key, value in pairs(autoloads) do
		if starts_with(dir, value:sub(1, -2)) then
			globalNamespace = key:sub(1, -2)
			dir = dir:sub(#key + 1)
			break
		end
	end
	dir = dir:gsub("/", "\\")
    if dir == "" then
        return globalNamespace
    end

	return string.format("%s\\%s", globalNamespace, dir)
end

return M
