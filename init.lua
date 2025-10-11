-- vim: foldmarker={{{,}}} foldlevel=1 foldmethod=marker

-- Plugin Init and Config {{{

-- Plugin Declaration {{{
vim.g.mapleader = " " -- ensure leader is set so subsequent mappings use it
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-mini/mini.nvim" },
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/folke/lazy.nvim" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/folke/lazydev.nvim" },
	{ src = "https://github.com/alexghergh/nvim-tmux-navigation" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/chrisgrieser/nvim-origami" },
	{ src = "https://github.com/f-person/auto-dark-mode.nvim" },
}, { load = true, confirm = false })
-- }}} End: Plugin Declaration
require("blink.cmp").setup()

-- auto-dark-mode {{{
require("auto-dark-mode").setup({
	set_dark_mode = function()
		vim.api.nvim_set_option_value("background", "dark", {})
		vim.cmd.colorscheme("catppuccin-macchiato")
	end,
	set_light_mode = function()
		vim.api.nvim_set_option_value("background", "light", {})
	end,
	update_interval = 500,
	fallback = "dark",
})
-- }}}

-- origami.nvim {{{
-- require("origami").setup({
-- 	useLspFoldsWithTreesitterFallback = true,
-- 	pauseFoldsOnSearch = true,
-- 	foldtext = {
-- 		enabled = true,
-- 		padding = 3,
-- 		lineCount = {
-- 			template = "-- %d lines", -- `%d` is replaced with the number of folded lines
-- 			hlgroup = "Comment",
-- 		},
-- 		diagnosticsCount = true, -- uses hlgroups and icons from `vim.diagnostic.config().signs`
-- 		gitsignsCount = true, -- requires `gitsigns.nvim`
-- 	},
-- 	autoFold = {
-- 		enabled = true,
-- 		kinds = { "comment", "imports" }, ---@type lsp.FoldingRangeKind[]
-- 	},
-- 	foldKeymaps = {
-- 		setup = true, -- modifies `h`, `l`, and `$`
-- 		hOnlyOpensOnFirstColumn = false,
-- 	},
-- })
-- }}}

-- conform.nvim {{{
-- TODO autoinstall the formatters with Mason
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff", "isort", "black" },
		rust = { "rustfmt", lsp_format = "fallback" },
		javascript = { "deno", stop_after_first = true },
		go = { "gofumpt", "golines", "goimport-reviser" },
		sh = { "shfmt" },
		lisp = { "cljfmt" },
	},
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
vim.keymap.set("n", "gm", function()
	require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 10000 })
end, { desc = "Format Files" })
-- }}}

-- nvim-tmux-navigation {{{
require("nvim-tmux-navigation").setup({
	disable_when_zoomed = false,
	keybindings = {
		left = "<C-h>",
		down = "<C-j>",
		up = "<C-k>",
		right = "<C-l>",
		last_active = "<C-\\>",
		next = "<C-Space>",
	},
})
-- }}}

-- lazydev.nvim {{{
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})
--}}}

-- oil.nvim {{{
require("oil").setup()
vim.keymap.set("n", "<leader>o", ":Oil<CR>")
-- }}}

-- snacks.nvim {{{
require("snacks").setup({
	picker = { enabled = true },
	dashboard = { enabled = true },
	explorer = { enabled = true },
	input = { enabled = true },
	notifier = { enabled = true },
	quickfile = { enabled = true },
	scroll = {
		animate = {
			-- duration = { step = 50, total = 500 },
			easing = "outSine",
		},
	},
	statuscolumn = { enabled = true },
	zen = { enabled = true },
	-- bufdelete = { enabled = true },
})
vim.keymap.set("n", "<C-b>", function()
	Snacks.picker.buffers({ layout = "vscode" })
end, { desc = "Snacks: Buffers" })
vim.keymap.set("n", "<C-n>", function()
	Snacks.picker.explorer({ layout = "right" })
end, { desc = "Snacks: Explorer" })
vim.keymap.set("n", "<leader>fp", function()
	Snacks.picker()
end, { desc = "Snacks: Pickers" })
vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.smart()
end, { desc = "Snacks: Files" })
vim.keymap.set("n", "<leader>fr", function()
	Snacks.picker.recent()
end, { desc = "Snacks: Recent" })
vim.keymap.set("n", "<leader>fs", function()
	Snacks.picker.git_status()
end, { desc = "Snacks: Git Status" })
vim.keymap.set("n", "<leader>fw", function()
	Snacks.picker.grep()
end, { desc = "Snacks: Grep" })
vim.keymap.set("n", "<leader><Space>", Snacks.picker.resume, { desc = "Snacks: Resume" })
vim.keymap.set("n", "<leader>fh", Snacks.picker.help, { desc = "Snacks: Help" })
-- }}}

-- mini.nvim {{{
require("mini.icons").setup()
require("mini.align").setup()
require("mini.bracketed").setup()
require("mini.comment").setup()
require("mini.move").setup()
require("mini.surround").setup()
require("mini.diff").setup({

	view = {
		style = "sign",
		signs = {
			add          = "┃",
			change       = "┃",
			delete       = "_",
			topdelete    = "‾",
			changedelete = "~",
			untracked    = "┆",
		},
	}
})

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

-- }}} End: Plugin Init and Config

---------------------------------------------------------------------------------------------------

-- {{{ Configs

-- {{{ Options
local opt = vim.opt
local o = vim.o

vim.g.mapleader = " "

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

vim.api.nvim_create_user_command("Commit", function()
	-- This causes git to create COMMIT_EDITMSG but not complete the commit
	vim.fn.system("GIT_EDITOR=true git commit -v")
	local git_dir = vim.fn.system("git rev-parse --git-dir"):gsub("\n", "")
	vim.cmd("tabedit! " .. git_dir .. "/COMMIT_EDITMSG")

	vim.api.nvim_create_autocmd("BufWritePost", {
		desc = "Execute git commit",
		pattern = "COMMIT_EDITMSG",
		once = true,
		callback = function()
			vim.fn.system("git commit -F " .. vim.fn.expand("%:p"))
		end,
	})
end, {})
-- }}} End: AutoCommands

-- {{{ Neovim Mappings
vim.keymap.set("i", "jk", "<ESC>", { desc = "Escape insert mode" })
vim.keymap.set("n", "gm", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>r", ":update<CR> :source<CR>")
vim.keymap.set("n", "<cr>", ":")

-- QoL
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join w/o cursor moving" })
vim.keymap.set("n", "<CR>", ":", { desc = "CMD enter command mode" })
vim.keymap.set("n", "<leader><Tab>", "<cmd> b# <CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "gh", "0", { desc = "Jump: Start of line" })
vim.keymap.set("n", "gl", "$", { desc = "Jump: End of line" })

vim.keymap.set("n", "q", "", { desc = "Unassing q key" })
vim.keymap.set("n", "\\", "q", { desc = "Macros" })
vim.keymap.set("n", "qo", "<cmd>copen<CR>", { desc = "Open QuickFix" })
vim.keymap.set("n", "qa", function()
	vim.fn.setqflist({ {
		filename = vim.fn.expand("%"),
		lnum = 1,
		col = 1,
		text = vim.fn.expand("%"),
	} }, "a")
end, { desc = "Add current file to QuickFix" })

-- Line numbers
vim.keymap.set("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "Toggle Line number" })
vim.keymap.set("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "Toggle Relative number" })

-- Window management
vim.keymap.set("n", "<leader>zi", "<cmd> wincmd | <CR>:wincmd _ <CR>", { desc = "Zoom Pane" })
vim.keymap.set("n", "<leader>zo", "<cmd> wincmd = <CR>", { desc = "Reset Zoom" })

-- Highlight Searching
vim.keymap.set("n", "c*", "*Ncgn", { desc = "Search and Replace 1x1" })
vim.keymap.set("v", "<C-r>", 'y:%s/<C-r>"//gc<left><left><left>', { desc = "Insert highlight as search string" })

-- Resize w/ Shift + Arrow Keys
vim.keymap.set("n", "<S-Up>", "<cmd>resize +2<CR>")             -- Increase height
vim.keymap.set("n", "<S-Down>", "<cmd>resize -2<CR>")           -- Decrease height
vim.keymap.set("n", "<S-Right>", "<cmd>vertical resize +5<CR>") -- Increase width
vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -5<CR>")  -- Decrease width

-- Smart highlight cancelling
vim.keymap.set("n", "n", "nzzzv:set cursorcolumn hlsearch<CR>")
vim.keymap.set("n", "N", "Nzzzv:set cursorcolumn hlsearch<CR>")

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
vim.keymap.set("n", "mm", "%")
-- Selects until matching pair, ex: `vm`
vim.keymap.set("x", "m", "%")
-- Use with operators, ex: `dm` - delete until matching pair
vim.keymap.set("o", "m", "%")

-------------------------------------- Tabline -----------------------------------------
vim.keymap.set("n", "]t", ":tabnext<CR>", { desc = "Next tab", silent = true })
vim.keymap.set("n", "[t", ":tabprevious<CR>", { desc = "Previous tab", silent = true })

-------------------------------------- Terminal -----------------------------------------
-- Terminal mode escape
--
vim.keymap.set("t", "<C-g>", "<C-\\><C-N>", { desc = "Terminal Escape terminal mode" })

-- Terminal Navigation
local function navigate_from_terminal(direction)
	return "<C-\\><C-N><C-w>" .. direction
end

vim.keymap.set("t", "<C-h>", navigate_from_terminal("h"))
vim.keymap.set("t", "<C-j>", navigate_from_terminal("j"))
vim.keymap.set("t", "<C-k>", navigate_from_terminal("k"))
vim.keymap.set("t", "<C-l>", navigate_from_terminal("l"))

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
vim.keymap.set(modes, "<leader>tr", function()
	local cmd = vim.fn.input("Command to run: ", last_cmd)
	if cmd and cmd ~= "" then
		last_cmd = cmd
		run_in_terminal(cmd, { direction = "tab" })
	end
end, { desc = "Run user command in terminal" })

vim.keymap.set(modes, "<leader>ts", function()
	local cmd = vim.fn.input("Command to run (vs): ", last_cmd)
	if cmd and cmd ~= "" then
		last_cmd = cmd
		run_in_terminal(cmd, { direction = "vsplit" })
	end
end, { desc = "Run user command in vertical split terminal" })
-- }}} End Mappings

-- }}} End: Configs
