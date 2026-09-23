local compile = {}
compile.keymaps = {}

local opts = {}

--- Map every key of a { modes = { key = cmd } } table
local function map_all(keys, map_opts)
	for modes, keymap in pairs(keys) do
		for key, cmd in pairs(keymap) do
			vim.keymap.set(require("compile.utils").split_to_char(modes), key, function()
				compile.keymaps.load(cmd)
			end, map_opts)
		end
	end
end

--- Setup keybindings for plugin
function compile.keymaps.setup(o)
	opts = o
	-- The terminal-global keys are mapped once here instead of being tied to the terminal buffer's
	-- lifetime: unlisting (`hidden`) or renaming that buffer fires BufDelete, which used to remove
	-- them right after they were created. The actions themselves are no-ops without a terminal.
	map_all(opts.keys.global, { silent = true })
	map_all(opts.keys.term.global, { silent = true })
end

--- Set the buffer-local keymaps of a freshly created terminal buffer
---@param buf integer
function compile.keymaps.attach(buf)
	map_all(opts.keys.term.buffer, { buffer = buf, silent = true })
end

--- Load keymaps
function compile.keymaps.load(code_str)
	local func, err = load(code_str)
	if not func then
		print("Error calling function " .. err)
	else
		local status, result = pcall(func)
		if not status then
			print("Runtime error " .. result)
		end
	end
end

return compile.keymaps
