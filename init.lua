-- vim: foldmarker={{{,}}} foldlevel=0 foldmethod=marker

-- {{{ Options
local map = vim.keymap.set
local opt = vim.opt
local g = vim.g
local o = vim.o

g.mapleader = " "

opt.autoread = true
opt.colorcolumn = "100"
opt.fillchars = { eob = " " }
opt.guifont = "CodeliaLigatures Nerd Font"
opt.scrolloff = 4
opt.shortmess:append("sI")
opt.swapfile = false
opt.whichwrap:append("<>[]hl")

o.clipboard = "unnamedplus"
o.cursorline = true
o.cursorlineopt = "both"
o.foldlevel = 99
o.foldlevelstart = 99
o.ignorecase = true
o.laststatus = 3
o.mouse = "a"
o.number = true
o.relativenumber = true
o.showmode = false
o.signcolumn = "auto:2"
o.smartcase = true
o.splitbelow = true
o.splitright = true
o.swapfile = false
o.tabstop = 4
o.termguicolors = true
o.timeoutlen = 500
o.undofile = true
o.updatetime = 500 -- used by gitsigns/CursorHold
o.winborder = "rounded"
o.wrap = false
-- Numbers
o.number = true
o.numberwidth = 2

-- add binaries installed by mise and mason.nvim to PATH
vim.env.PATH = vim.env.PATH .. ":" .. vim.env.XDG_DATA_HOME .. "/mise/shims"
vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"
-- }}} End Options

-- {{{ Plugin Declaration
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-mini/mini.nvim" },
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/folke/lazy.nvim" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/folke/lazydev.nvim" },
})
-- }}} End: Plugin Declaration

-- {{{ Plugin Init and Config
vim.cmd("colorscheme catppuccin-macchiato")
require("oil").setup()
require("blink.cmp").setup()
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})

-- snacks.nvim {{{
require("snacks").setup({
	picker = { enabled = true },
	dashboard = { enabled = true },
	explorer = { enabled = true },
	input = { enabled = true },
})

-- map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files" })
map("n", "<leader>ff", Snacks.picker.smart, { desc = "Snacks Files" })
map("n", "<leader>fr", Snacks.picker.recent, { desc = "Snacks Recent" })
map("n", "<leader>fs", Snacks.picker.git_status, { desc = "Snacks Git Status" })
map("n", "<leader>fw", Snacks.picker.grep, { desc = "Snacks Grep" })
map("n", "<leader><Space>", Snacks.picker.resume, { desc = "Snacks Resume" })
map("n", "<C-n>", Snacks.picker.explorer, { desc = "Snacks Explorer" })
map("n", "<C-b>", Snacks.picker.buffers, { desc = "Snacks Explorer" })
-- }}}

-- mini.nvim {{{
require("mini.icons").setup()
-- require("mini.pick").setup()
require("mini.align").setup()
require("mini.bracketed").setup()
require("mini.comment").setup()
require("mini.move").setup()
require("mini.surround").setup()
require("mini.diff").setup()

require("mini.ai").setup({
	n_lines = 500,
	custom_textobjects = {
		m = {
			{ "%b()", "%b[]", "%b{}" },
			"^.().*().$",
		},
	},
})

require("mini.indentscope").setup({
	symbol = "┃",

	draw = {
		delay = 40,
		priority = 2,
		animation = require("mini.indentscope").gen_animation.exponential({
			easing = "in-out",
			duration = 80,
			unit = "total",
		}),
	},
})

require("mini.bufremove").setup()
vim.keymap.set("n", "<leader>q", require("mini.bufremove").delete, { desc = "Close buffer, keep split" })

local disabled = { "help", "terminal" }
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		if disabled[vim.bo.filetype] ~= nil or vim.bo.buftype ~= "" then
			vim.b.miniindentscope_disable = true
		end
	end,
})

vim.cmd([[highlight! link MiniIndentscopeSymbol Identifier]])
-- }}}

-- {{{ TreeSitter
local ts_lang = {
	-- web dev
	"html",
	"css",
	"javascript",
	"typescript",
	"tsx",
	"json",
	"vue",
	"svelte",

	-- other
	"c",
	"go",
	"rust",
	"glsl",
	"ruby",
	"typst",
	"python",
	"lua",
	"hcl",
	"terraform",
	"markdown",
	"markdown_inline",
	"luadoc",
	"printf",
	"regex",
	"vim",
	"vimdoc",
	"yaml",
}

require("nvim-treesitter").install(ts_lang)
require("nvim-treesitter").setup()

vim.api.nvim_create_autocmd("FileType", {
	desc = "Load tree-sitter for supported file types",
	pattern = ts_lang,
	callback = function()
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		vim.treesitter.start()
	end,
})

-- }}}

-- }}} End: Plugin Init and Config

-- {{{ Plugin Mappings
-- vim.keymap.set("n", "<leader>ff", ":Pick files<CR>")
vim.keymap.set("n", "<leader>fh", ":Pick help<CR>")
vim.keymap.set("n", "<leader>o", ":Oil<CR>")
-- }}} End: Plugin Mappings

-- {{{ LSP and Completion
require("mason").setup()

local lsps = {
	"basedpyright",
	"denols",
	"gopls",
	"lua_ls",
	"markdown_oxide",
	"ruff",
	"rust_analyzer",
	"tinymist",
	"yamlls",
	"zls",
}

vim.lsp.enable(lsps)
-- require("mason.api.command").MasonInstall(lsps)

-- Register completion capabilities universally
vim.lsp.config("*", {
	capabilities = require('blink.cmp').get_lsp_capabilities()
})

local custom = {
	ruff = {
		settings = {
			lineLength = 100,
			lint = { preview = true },
			format = { preview = true },
		},
	},

	basedpyright = {
		settings = {
			basedpyright = {
				analysis = {
					disableOrganizeImports = true, -- address conflict w/ ruff
					typeCheckingMode = "off", -- ditto
					diagnosticMode = "workspace",
					useLibraryCodeForTypes = true,
				},
			},
		},
	},

	-- vim.lsp.config (vim.tbl_deep_extend) doesn't merge lists, so we do it here
	denols = { filetypes = vim.tbl_extend("keep", { "json", "jsonc" }, vim.lsp.config.denols.filetypes) },
}

for server, config in pairs(custom) do
	vim.lsp.config(server, config)
end


local x = vim.diagnostic.severity
vim.diagnostic.config({
	update_in_insert = false,
	signs = { text = { [x.ERROR] = "󰅙", [x.WARN] = "", [x.INFO] = "󰋼", [x.HINT] = "󰌵" } },
	virtual_text = { current_line = true, severity = { min = x.HINT } },
	severity_sort = true,
	underline = true,
	float = { border = "single" },
})
-- }}} End: LSP and Completion

-- {{{ AutoCommands

-- vim.api.nvim_create_autocmd("LspAttach", {
-- 	callback = function(ev)
-- 		local client = vim.lsp.get_client_by_id(ev.data.client_id)
-- 		if client:supports_method("textDocument/completion") then
-- 			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
-- 		end
-- 	end,
-- })
--

-----------------------------------Auto-Commands-------------------------------------
-- highlight yanked text for 300ms using the "Visual" highlight group
--
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Reload files if changed externally
--
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
	desc = "Reload files if changed externally",
	command = "if mode() != 'c' | checktime | endif",
	pattern = { "*" },
})

-- show cursor line only in active window
--
vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter" }, {
	desc = "Show cursor line only in active window",
	callback = function()
		if vim.w.auto_cursorline then
			vim.wo.cursorline = true
			vim.w.auto_cursorline = nil
		end
	end,
})
vim.api.nvim_create_autocmd({ "InsertEnter", "WinLeave" }, {
	desc = "Hide cursor line when leaving insert mode or window",
	callback = function()
		if vim.wo.cursorline then
			vim.w.auto_cursorline = true
			vim.wo.cursorline = false
		end
	end,
})

-- More specific autocmd that only triggers on window focus
--
vim.api.nvim_create_autocmd("BufWinEnter", {
	desc = "Set up quickfix window keybindings",
	pattern = "*",
	group = vim.api.nvim_create_augroup("qf", { clear = true }),
	callback = function()
		if vim.bo.buftype == "quickfix" then
			vim.keymap.set("n", "qc", ":ccl<cr>", { buffer = true })
			vim.keymap.set("n", "<cr>", "<cr>", { buffer = true })

			vim.keymap.set("n", "1", "1G<cr>:ccl<cr>", { buffer = true })
			vim.keymap.set("n", "2", "2G<cr>:ccl<cr>", { buffer = true })
			vim.keymap.set("n", "3", "3G<cr>:ccl<cr>", { buffer = true })
			vim.keymap.set("n", "4", "4G<cr>:ccl<cr>", { buffer = true })

			vim.keymap.set("n", "dd", function()
				local qflist = vim.fn.getqflist()
				table.remove(qflist, vim.fn.line("."))
				vim.fn.setqflist(qflist, "r")
			end, { buffer = true })
		end
	end,
})

-- Enter insert mode when focusing terminal
--
vim.api.nvim_create_autocmd("WinEnter", {
	desc = "Enter insert mode when focusing terminal",
	pattern = "*",
	group = vim.api.nvim_create_augroup("term_insert", { clear = true }),
	callback = function()
		if vim.bo.buftype == "terminal" then
			vim.cmd("startinsert")
		end
	end,
})
-- }}} End: AutoCommands

-- {{{ Neovim Mappings
map("i", "jk", "<ESC>", { desc = "Escape insert mode" })
map("n", "gm", vim.lsp.buf.format)
map("n", "<leader>r", ":update<CR> :source<CR>")
map("n", "<cr>", ":")

-- QoL
map("n", "J", "mzJ`z", { desc = "Join w/o cursor moving" })
map("n", "<CR>", ":", { desc = "CMD enter command mode" })
map("n", "<leader><Tab>", "<cmd> b# <CR>", { desc = "Previous Buffer" })
map("n", "gh", "0", { desc = "Jump: Start of line" })
map("n", "gl", "$", { desc = "Jump: End of line" })

map("n", "q", "", { desc = "Unassing q key" })
map("n", "\\", "q", { desc = "Macros" })
map("n", "qo", "<cmd>copen<CR>", { desc = "Open QuickFix" })
map("n", "qa", function()
	vim.fn.setqflist({ {
		filename = vim.fn.expand("%"),
		lnum = 1,
		col = 1,
		text = vim.fn.expand("%"),
	} }, "a")
end, { desc = "Add current file to QuickFix" })

-- Line numbers
map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "Toggle Line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "Toggle Relative number" })

-- Window management
map("n", "<leader>zi", "<cmd> wincmd | <CR>:wincmd _ <CR>", { desc = "Zoom Pane" })
map("n", "<leader>zo", "<cmd> wincmd = <CR>", { desc = "Reset Zoom" })

-- Highlight Searching
map("n", "c*", "*Ncgn", { desc = "Search and Replace 1x1" })
map("v", "<C-r>", 'y:%s/<C-r>"//gc<left><left><left>', { desc = "Insert highlight as search string" })

-- Resize w/ Shift + Arrow Keys
map("n", "<S-Up>", "<cmd>resize +2<CR>")             -- Increase height
map("n", "<S-Down>", "<cmd>resize -2<CR>")           -- Decrease height
map("n", "<S-Right>", "<cmd>vertical resize +5<CR>") -- Increase width
map("n", "<S-Left>", "<cmd>vertical resize -5<CR>")  -- Decrease width

-- Smart highlight cancelling
map("n", "n", "nzzzv:set cursorcolumn hlsearch<CR>")
map("n", "N", "Nzzzv:set cursorcolumn hlsearch<CR>")

vim.on_key(function(char)
	if vim.fn.mode() == "n" then
		local new_hlsearch = vim.tbl_contains({ "<CR>", "*", "#", "?", "/" }, vim.fn.keytrans(char))
		if vim.opt.hlsearch ~= new_hlsearch then
			vim.opt.hlsearch = new_hlsearch
			vim.opt.cursorcolumn = false
		end
	end
end, vim.api.nvim_create_namespace("auto_hlsearch"))
------------------------------------ Brace Match ---------------------------------------
-- NOTE custom objects config'd in mini.ai plugin
map("n", "mm", "%")
-- Selects until matching pair, ex: `vm`
map("x", "m", "%")
-- Use with operators, ex: `dm` - delete until matching pair
map("o", "m", "%")

-------------------------------------- Tabline -----------------------------------------
map("n", "]t", ":tabnext<CR>", { desc = "Next tab", silent = true })
map("n", "[t", ":tabprevious<CR>", { desc = "Previous tab", silent = true })

map("n", "<leader>tt", function()
	require("i3tab").toggle_tabline()
end, { desc = "Toggle [t]abs" })

-------------------------------------- Terminal -----------------------------------------
-- Terminal mode escape
--
map("t", "<C-g>", "<C-\\><C-N>", { desc = "Terminal Escape terminal mode" })

-- Terminal Navigation
local function navigate_from_terminal(direction)
	return "<C-\\><C-N><C-w>" .. direction
end

map("t", "<C-h>", navigate_from_terminal("h"))
map("t", "<C-j>", navigate_from_terminal("j"))
map("t", "<C-k>", navigate_from_terminal("k"))
map("t", "<C-l>", navigate_from_terminal("l"))

local modes = { "n", "t" }
local function run_in_terminal(cmd, opts)
	opts = opts or {}
	local direction = opts.direction or "normal"
	if direction == "vsplit" then
		vim.cmd("vsplit")
	elseif direction == "hsplit" then
		vim.cmd("split")
	elseif direction == "tab" then
		vim.cmd("tabnew")
	elseif direction == "float" then
		-- TODO floating window logic
	end
	local term_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(0, term_buf)
	---@diagnostic disable-next-line: deprecated
	vim.fn.termopen(cmd, opts or {})
end

local last_cmd = ""
map(modes, "<leader>tr", function()
	local cmd = vim.fn.input("Command to run: ", last_cmd)
	if cmd and cmd ~= "" then
		last_cmd = cmd
		run_in_terminal(cmd, { direction = "tab" })
	end
end, { desc = "Run user command in terminal" })

map(modes, "<leader>ts", function()
	local cmd = vim.fn.input("Command to run (vs): ", last_cmd)
	if cmd and cmd ~= "" then
		last_cmd = cmd
		run_in_terminal(cmd, { direction = "vsplit" })
	end
end, { desc = "Run user command in vertical split terminal" })
-- }}} End Mappings
