---@diagnostic disable: missing-fields
-- vim: foldmarker={{{,}}} foldlevel=1 foldmethod=marker

-- Plugin Init and Config {{{

-- Plugin Declaration {{{
vim.g.mapleader = " " -- ensure leader is set so subsequent mappings use it
vim.cmd.packadd("nohlsearch")
vim.pack.add({
	-- Deps and Extensions
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/nvzone/volt" },
	-- Core
	{ src = "https://github.com/audibleblink/i3tab.nvim" },
	{ src = "https://github.com/alexghergh/nvim-tmux-navigation" },
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/chrisgrieser/nvim-origami" },
	{ src = "https://github.com/f-person/auto-dark-mode.nvim" },
	{ src = "https://github.com/folke/lazydev.nvim" },
	{ src = "https://github.com/folke/noice.nvim" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/folke/sidekick.nvim" },
	{ src = "https://github.com/folke/trouble.nvim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/nvim-mini/mini.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
	-- { src = "https://github.com/nvzone/floaterm" },
	{ src = "https://github.com/audibleblink/floaterm", version = "feature/open" },
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/jiaoshijie/undotree" },
}, { load = true, confirm = false })
-- }}} End: Plugin Declaration

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

-- blink.cmp {{{
require("blink.cmp").setup({
	completion = {
		menu = { auto_show = false },
		ghost_text = { enabled = false },
	},
	keymap = {
		preset = "default",
		["<C-l>"] = { "accept" },
		["<Tab>"] = {
			"snippet_forward",
			function() -- sidekick next edit suggestion
				return require("sidekick").nes_jump_or_apply()
			end,
			function() -- if you are using Neovim's native inline completions
				return vim.lsp.inline_completion.get()
			end,
			"fallback",
		},
	},
})
-- }}}

-- conform.nvim {{{
-- TODO autoinstall the formatters with Mason
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff", "isort", "black" },
		rust = { "rustfmt", lsp_format = "fallback" },
		javascript = { "deno", stop_after_first = true },
		go = { "gofumpt", "golines", "goimports-reviser" },
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

-- i3tab {{{
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		require("i3tab").setup({
			separator_style = "dot",
			show_numbers = false,
			colors = {
				active = {
					fg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg,
					bg = vim.api.nvim_get_hl(0, { name = "TabLineSel" }).bg,
				},
				inactive = {
					fg = vim.api.nvim_get_hl(0, { name = "Normal" }).fg,
					bg = vim.api.nvim_get_hl(0, { name = "TabLineSel" }).fg,
				},
			},
		})
	end,
})
-- }}}

-- floaterm {{{
require("floaterm").setup({
	size = { h = 70, w = 80 },
	mappings = {
		sidebar = nil,
		term = function(buf)
			vim.keymap.set({ "n", "t" }, "``", function()
				require("floaterm").toggle()
			end, { buffer = buf })
		end,
	},
})

vim.keymap.set({ "n", "t" }, "``", require("floaterm").toggle, { desc = "Floaterm: Toggle" })

vim.keymap.set("n", "ghP", function()
	require("floaterm.api").open_and_run({ name = "Git", cmd = "git push" })
end, { desc = "[Git] Floaterm: Push" })

vim.keymap.set("n", "ghl", function()
	require("floaterm.api").open_and_run({
		name = "Git",
		cmd = [[git log --graph --decorate --all --pretty=format:"%C(cyan)%h%Creset %C()%s%Creset%n%C(dim italic white)      └─ %ar by %an %C(auto)  %D%n"]],
	})
end, { desc = "[Git] Floaterm: Log" })

-- }}}

-- gitsigns.nvim {{{
require("gitsigns").setup({
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")

		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		-- Navigation
		map("n", "]g", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]g", bang = true })
			else
				gitsigns.nav_hunk("next")
			end
		end, { desc = "[Git] Next Hunk" })

		map("n", "[g", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[g", bang = true })
			else
				gitsigns.nav_hunk("prev")
			end
		end, { desc = "[Git] Prev Hunk" })

		-- Actions
		map("v", "ghs", function()
			gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "[Git] Stage Hunk" })

		map("v", "ghr", function()
			gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
		end, { desc = "[Git] Reset Hunk" })

		map("n", "ghs", gitsigns.stage_hunk, { desc = "[Git] Stage Hunk" })
		map("n", "ghr", gitsigns.reset_hunk, { desc = "[Git] Reset Hunk" })
		map("n", "ghS", gitsigns.stage_buffer, { desc = "[Git] Stage Buffer" })
		map("n", "ghR", gitsigns.reset_buffer, { desc = "[Git] Reset Buffer" })
		map("n", "ghp", gitsigns.preview_hunk, { desc = "[Git] Preview Hunk" })
		map("n", "ghi", gitsigns.preview_hunk_inline, { desc = "[Git] Preview Hunk Inline" })
		map("n", "ghd", gitsigns.diffthis, { desc = "[Git] Diff This" })

		map("n", "ghb", function()
			gitsigns.blame_line({ full = true })
		end, { desc = "[Git] Blame Hunk" })

		-- map("n", "<leader>gD", function()
		-- 	gitsigns.diffthis("~")
		-- end, { desc = "[Git] Diff This" })

		map("n", "ghQ", function()
			gitsigns.setqflist("all")
		end, { desc = "[Git] Send All Hunks to QF" })
		map("n", "ghq", gitsigns.setqflist, { desc = "[Git] Send Hunk to QF" })

		-- Motion-based hunk staging
		local function stage_hunk_operator()
			local start_pos = vim.api.nvim_buf_get_mark(0, "[")
			local end_pos = vim.api.nvim_buf_get_mark(0, "]")
			gitsigns.stage_hunk({ start_pos[1], end_pos[1] })
		end

		-- Toggles
		map("n", "<leader>ghtb", gitsigns.toggle_current_line_blame, { desc = "[Git] Toggle Line Blame" })
		map("n", "<leader>ghtw", gitsigns.toggle_word_diff, { desc = "[Git] Toggle Word Diff" })

		map("n", "gs", function()
			_G._stage_hunk_operator = stage_hunk_operator
			vim.o.operatorfunc = "v:lua._stage_hunk_operator"
			return "g@"
		end, { expr = true, desc = "[Git] Stage hunk with motion" })

		-- Text objects
		map({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "[Git] Hunk" })
		map("n", "gss", "gsih", { desc = "[Git] Stage Hunk", remap = true })
	end,
})
-- }}}

-- lazydev.nvim {{{
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})
--}}}

-- lualine.nvim {{{
--
require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "auto",
		component_separators = "",
		section_separators = { left = "", right = "" },
		globalstatus = true,

		refresh = {
			statusline = 33,
			refresh_time = 33, -- ~60fps
		},
	},
	sections = {
		lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
		lualine_b = { "filename" },
		lualine_c = {
			{
				require("noice").api.status.mode.get_hl, ---@diagnostic disable-line: undefined-field
				cond = require("noice").api.status.mode.has, ---@diagnostic disable-line: undefined-field
				icon = "󰑋",
				color = { fg = "#ff0000" },
			},
			"%=",
			"diagnostics",
		},
		lualine_x = {
			{
				"lsp_status",
				icon = " ",
				ignore_lsp = { "copilot", "stylua" },
			},
		},
		lualine_y = { "branch" },
		lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { "filename" },
		lualine_x = { "location" },
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = { "quickfix", "mason", "oil", "trouble" },
})
-- }}}

-- mini.nvim {{{
require("mini.align").setup()
require("mini.bracketed").setup()
require("mini.comment").setup()
require("mini.icons").setup()
require("mini.move").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.bufremove").setup()
vim.keymap.set("n", "<leader>q", require("mini.bufremove").delete, { desc = "Close buffer, keep split" })

require("mini.ai").setup({
	n_lines = 500,
	custom_textobjects = {
		m = {
			{ "%b()", "%b[]", "%b{}" },
			"^.().*().$",
		},
	},
})

require("mini.clue").setup({
	triggers = {
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		-- Built-in completion
		{ mode = "i", keys = "<C-x>" },
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		{ mode = "n", keys = "]" },
		{ mode = "n", keys = "[" },
		{ mode = "x", keys = "]" },
		{ mode = "x", keys = "[" },
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },
		-- Registers
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },
		-- Window commands
		{ mode = "n", keys = "<C-w>" },
		-- `z` key
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },
	},
	clues = {
		-- Enhance this by adding descriptions for <Leader> mapping groups
		require("mini.clue").gen_clues.builtin_completion(),
		require("mini.clue").gen_clues.g(),
		require("mini.clue").gen_clues.marks(),
		require("mini.clue").gen_clues.registers(),
		require("mini.clue").gen_clues.windows(),
		require("mini.clue").gen_clues.z(),
	},
	window = {
		delay = 400,
		config = { anchor = "NE", row = "auto", col = "auto" },
	},
})

-- require("mini.diff").setup({
-- 	view = {
-- 		style = "sign",
-- 		signs = { add = "┃", change = "┃", delete = "_" },
-- 	},
-- })

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

-- noice.nvim {{{

require("noice").setup({
	lsp = {
		signature = { enabled = false },
		hover = { enabled = false },
		progress = { enabled = true },
	},
	views = {
		cmdline_popup = {
			size = { min_width = 66 },
			position = { row = "90%" },
			border = { style = { "", " ", "", " ", "", " ", "", " " } },
			win_options = { winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder" },
		},
		cmdline_input = {
			view = "cmdline_popup",
			border = { style = { "", " ", "", " ", "", " ", "", " " } },
			win_options = { winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder" },
		},
	},
	timeout = 1000,
	fps = 60,
	routes = {
		{
			filter = { find = "No information available" },
			view = "mini",
		},
		{
			filter = { find = "written" },
			view = "mini",
		},
		{
			filter = { find = "Successfully applied" },
			view = "mini",
		},
	},
})

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

-- oil.nvim {{{
require("oil").setup()
vim.keymap.set("n", "<leader>o", ":Oil<CR>", { desc = "Oil: File Browser" })
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

-- render-markdown.nvim {{{
require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
	render_modes = true, -- Render in ALL modes
	sign = {
		enabled = false, -- Turn off in the status column
	},
	latex = { enabled = false },
	overrides = {
		filetype = {
			codecompanion = {
				html = {
					tag = {
						buf = { icon = " ", highlight = "CodeCompanionChatIcon" },
						file = { icon = " ", highlight = "CodeCompanionChatIcon" },
						group = { icon = " ", highlight = "CodeCompanionChatIcon" },
						help = { icon = "󰘥 ", highlight = "CodeCompanionChatIcon" },
						image = { icon = " ", highlight = "CodeCompanionChatIcon" },
						symbols = { icon = " ", highlight = "CodeCompanionChatIcon" },
						tool = { icon = "󰯠 ", highlight = "CodeCompanionChatIcon" },
						url = { icon = "󰌹 ", highlight = "CodeCompanionChatIcon" },
					},
				},
			},
		},
	},
})
-- }}}

-- sidekick.nvim {{{
require("sidekick").setup({
	cli = {
		mux = {
			backend = "tmux",
			enabled = true,
		},
	},
})
vim.keymap.set("n", "<leader>ai", function()
	require("sidekick.cli").toggle()
end, { desc = "Sidekick: Toggle" })

vim.keymap.set("n", "<leader>ap", function()
	require("sidekick.cli").prompt()
end, { desc = "Sidekick: Prompt" })

vim.keymap.set({ "n", "x" }, "<tab>", function()
	-- if there is a next edit, jump to it, otherwise apply it if any
	if not require("sidekick").nes_jump_or_apply() then
		return "<Tab>" -- fallback to normal tab
	end
end, { desc = "Sidekick: Next Edit", expr = true })

vim.keymap.set({ "n", "x" }, "<leader>at", function()
	require("sidekick.cli").send({ msg = "{this}" })
end, { desc = "Sidekick: Send Reference" })

vim.keymap.set("n", "<leader>af", function()
	require("sidekick.cli").send({ msg = "{file}" })
end, { desc = "Sidekick: Send File" })

vim.keymap.set("x", "<leader>av", function()
	require("sidekick.cli").send({ msg = "{selection}" })
end, { desc = "Sidekick: Send Literal Selection" })
-- }}}

-- snacks.nvim {{{
require("snacks").setup({
	picker = { enabled = true },
	dashboard = {
		preset = {
			header = [[
░▀█▀░▄▀▀▄░█▀▄▀█░▄▀▀▄░█▀▀▄░█▀▀▄░▄▀▀▄░█░░░█
░░█░░█░░█░█░▀░█░█░░█░█▄▄▀░█▄▄▀░█░░█░▀▄█▄▀
░░▀░░░▀▀░░▀░░▒▀░░▀▀░░▀░▀▀░▀░▀▀░░▀▀░░░▀░▀░
  ░█▀▀█░▄▀▀▄░█▀▄▀█░█▀▀░█▀▀
  ░█░░░░█░░█░█░▀░█░█▀▀░▀▀▄
  ░▀▀▀▀░░▀▀░░▀░░▒▀░▀▀▀░▀▀▀]],
			keys = {
				{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
				{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
				{ icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
				{ icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
				{
					icon = " ",
					key = "d",
					desc = "Config",
					action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
				},
				{
					icon = " ",
					key = "s",
					desc = "Scratch Buffer",
					action = ":enew | setlocal buftype=nofile bufhidden=hide noswapfile",
				},
				{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
			},
			-- Used by the `header` section
		},
		sections = {
			{ section = "header" },
			{ section = "keys", gap = 1, padding = 1 },
			-- { section = "startup" },
		},
	},
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
	statuscolumn = {
		left = { "sign", "git", "mark" },
		right = { "fold" },
		folds = { open = true },
	},
	zen = { enabled = true },
	-- bufdelete = { enabled = true },
})
vim.keymap.set("n", "<C-b>", function()
	Snacks.picker.buffers({ layout = "vscode" })
end, { desc = "Snacks: Buffers" })
vim.keymap.set("n", "<C-n>", function()
	Snacks.picker.explorer({ layout = "right" })
end, { desc = "Snacks: Explorer" })
vim.keymap.set("n", "<leader>fa", function()
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
vim.keymap.set("n", "<leader>fpp", function()
	Snacks.picker.files({ dirs = { vim.fn.stdpath("data") .. "/site/pack/core/opt" } })
end, { desc = "Snacks: Plugins" })
vim.keymap.set("n", "<leader>fpa", function()
	Snacks.picker.grep({ dirs = { vim.fn.stdpath("data") .. "/site/pack/core/opt" } })
end, { desc = "Snacks: Grep Plugins" })
vim.keymap.set("n", "<leader><Space>", Snacks.picker.resume, { desc = "Snacks: Resume" })
vim.keymap.set("n", "<leader>fh", Snacks.picker.help, { desc = "Snacks: Help" })
-- }}}

-- {{{ tree-sitter
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
--
-- trouble.nvim {{{
require("trouble").setup({
	icons = {
		indent = {
			ws = " ",
			top = "│ ",
			middle = "├╴",
			last = "└╴",
			-- last          = "-╴",
			-- last       = "╰╴", -- rounded
			fold_open = " ",
			fold_closed = " ",
		},
		folder_closed = "",
		folder_open = "",
		kinds = {
			Array = "",
			Boolean = "󰨙",
			Class = "",
			Constant = "󰏿",
			Constructor = "",
			Enum = "",
			EnumMember = "",
			Event = "",
			Field = "",
			File = "",
			Function = "󰊕",
			Interface = "",
			Key = "",
			Method = "󰊕",
			Module = "",
			Namespace = "󰦮",
			Null = "",
			Number = "󰎠",
			Object = "",
			Operator = "",
			Package = "",
			Property = "",
			String = "",
			Struct = "󰆼",
			TypeParameter = "",
			Variable = "󰀫",
		},
	},
	modes = {
		symbols = {
			focus = false,
			win = { position = "left" },
			mode = "lsp_document_symbols",
		},
	},
})

local trouble = require("trouble")

vim.keymap.set("n", "<M-n>", function()
	trouble.toggle({ mode = "symbols" })
end, { desc = "Symbols Outline" })

vim.keymap.set("n", "<leader>xq", function()
	trouble.toggle({ mode = "qflist" })
end, { desc = "Quickfix List (Trouble)" })

vim.keymap.set("n", "<leader>xX", function()
	trouble.toggle({ mode = "diagnostics" })
end, { desc = "Diagnostic List (Trouble)" })

vim.keymap.set("n", "<leader>xx", function()
	trouble.toggle({ mode = "diagnostics", filter = { buf = 0 } })
end, { desc = "Location List (Trouble)" })
-- }}}
--
-- undotree {{{
require("undotree").setup()
vim.keymap.set("n", "<leader>u", require("undotree").toggle, { noremap = true, silent = true, desc = "UndoTree" })
-- }}}

-- {{{ LSP and Completion (Mason)
_G.debuggers = {
	"delve",
	"debugpy",
}

_G.lang_servers = {
	"basedpyright",
	"copilot",
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

require("mason").setup({ max_concurrent_installers = 8 })
require("mason-lspconfig").setup({ ensure_installed = _G.lang_servers })

-- Register completion capabilities universally
vim.lsp.config("*", {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
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
	denols = {
		filetypes = vim.tbl_extend("keep", { "json", "jsonc" }, vim.lsp.config.denols.filetypes),
	},
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

---{{{ Configs

-- {{{ Options
vim.cmd.colorscheme("catppuccin-macchiato")
local opt = vim.opt
local o = vim.o

opt.autoread = true
opt.colorcolumn = "100"
opt.fillchars = { eob = " " }
opt.guifont = "CodeliaLigatures Nerd Font"
opt.scrolloff = 4
opt.shortmess:append("sI")
opt.swapfile = false
opt.whichwrap:append("<>[]hl")
opt.foldlevel = 99
opt.foldlevelstart = 99

o.clipboard = "unnamedplus"
o.cursorline = true
o.cursorlineopt = "both"
o.ignorecase = true
o.laststatus = 3
o.mouse = "a"
o.number = true
o.relativenumber = true
o.showmode = false
o.smartcase = true
o.splitbelow = true
o.splitright = true
o.swapfile = false
o.tabstop = 4
o.termguicolors = true
o.timeoutlen = 500
o.undofile = true
o.winborder = "rounded"
o.wrap = false
-- Numbers
o.number = true
o.numberwidth = 2

-- add binaries installed by mise
vim.env.PATH = vim.env.PATH .. ":" .. vim.env.XDG_DATA_HOME .. "/mise/shims"
-- }}} End Options

-- {{{ AutoCommands

vim.api.nvim_create_user_command("MasonInstallAll", function()
	local mason_packages = {}
	vim.list_extend(mason_packages, _G.debuggers)
	for _, v in ipairs(require("conform").list_all_formatters()) do
		local fmts = vim.split(v.name:gsub(",", ""), "%s+")
		vim.list_extend(mason_packages, fmts)
	end

	vim.cmd("Mason")
	local mr = require("mason-registry")
	mr.refresh(function()
		for _, tool in ipairs(mason_packages) do
			local pkg = { name = tool, version = nil }
			local p = mr.get_package(pkg.name)

			if not p:is_installed() then
				p:install({ version = pkg.version })
			end
		end
	end)
end, {})

-- Create project-specific shada-files
--
opt.shadafile = (function()
	local git_root = vim.fs.root(0, ".git")
	if not git_root then
		return
	end
	local shadafile = vim.fs.joinpath(vim.fn.stdpath("state"), "_shada", vim.base64.encode(git_root))
	vim.fn.mkdir(vim.fs.dirname(shadafile), "p")
	return shadafile
end)()

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

-- Git commit within current session
--
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
vim.keymap.set("n", "ghc", vim.cmd.Commit, { desc = "Git Commit" })
-- }}} End: AutoCommands

-- {{{ Neovim Mappings
vim.keymap.set("i", "<C-s>", "<cmd>w<cr>", { desc = "Join w/o cursor moving" })
vim.keymap.set("i", "jk", "<ESC>", { desc = "Escape insert mode" })
vim.keymap.set("n", "<leader>rr", ":update<CR> :source<CR>", { desc = "Source current file" })
vim.keymap.set("n", "<cr>", ":")

-- QoL
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join w/o cursor moving" })
vim.keymap.set("n", "<CR>", ":", { desc = "CMD enter command mode" })
vim.keymap.set("n", "<leader><Tab>", "<cmd> b# <CR>", { desc = "Previous Buffer" })
vim.keymap.set("n", "<left>", "0", { desc = "Jump: Start of line" })
vim.keymap.set("n", "<right>", "$", { desc = "Jump: End of line" })

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
vim.keymap.set("n", "<S-Up>", "<cmd>resize +2<CR>") -- Increase height
vim.keymap.set("n", "<S-Down>", "<cmd>resize -2<CR>") -- Decrease height
vim.keymap.set("n", "<S-Right>", "<cmd>vertical resize +5<CR>") -- Increase width
vim.keymap.set("n", "<S-Left>", "<cmd>vertical resize -5<CR>") -- Decrease width

-- Smart highlight cancelling
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

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

-- }}} End Mappings

-- }}} End: Configs
