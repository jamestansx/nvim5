local api, opt = vim.api, vim.opt
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup
local keymap = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

-- disable default plugins
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

-- gloabl augroup
augroup("global", { clear = true })

--- [options] ---
opt.breakindent = true
opt.confirm = true
opt.cursorline = true
opt.cursorlineopt = "number"
opt.expandtab = true
opt.exrc = true
opt.hlsearch = false
opt.isfname:append("@-@")
opt.jumpoptions:append("stack,view")
opt.laststatus = 3
opt.linebreak = true
opt.matchpairs:append("<:>")
opt.mousemodel = "extend"
opt.scrolloff = 5
opt.selection = "old" -- don't select past line
opt.shada = { "'10", "<0", "s10", "h", "/10", "r/tmp" }
opt.shiftround = true
opt.shiftwidth = 4
opt.shortmess:append("IcAa")
opt.showcmd = false
opt.showmode = false
opt.signcolumn = "yes:1"
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 4
opt.termguicolors = true
opt.undofile = true
opt.virtualedit = "block"
opt.wrap = false

opt.number = true
opt.numberwidth = 1
opt.relativenumber = true

opt.completeopt = "menuone,noselect,fuzzy"
opt.pumheight = 5
opt.wildcharm = (""):byte()
opt.wildignore:append("*/__pycache__/*,*/node_modules/*")
opt.wildmode = "longest:full,full"

-- improve search
opt.ignorecase = true
opt.inccommand = "split"
opt.smartcase = true

opt.list = true
opt.listchars = {
    extends  = "🠞",  -- U+1F81E
    nbsp     = "⦸",  -- U+29B8
    precedes = "🠜",  -- U+1F81C
    tab      = "▸ ", -- U+25B8
    trail    = "·",  -- U+00B7
}

opt.diffopt:append({
    "algorithm:histogram",
    "indent-heuristic",
    "linematch:60",
})

if vim.fn.executable("rg") == 1 then
    opt.grepprg = "rg --no-heading --smart-case --vimgrep"
    opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

-- ftplugin may include 'o' option
autocmd("FileType", {
    group = "global",
    callback = function()
        opt.formatoptions:remove("o")
    end,
})

vim.diagnostic.config({
    severity_sort = true,
    jump = { float = true },
})

--- [autocommand] ---
autocmd("TextYankPost", {
    group = "global",
    callback = function()
        vim.hl.on_yank({ timeout = 100 })
    end,
})

autocmd("BufReadPost", {
    group = "global",
    callback = function()
        local tbl_excludes = { "gitcommit", "gitrebase", "help" }
        if vim.tbl_contains(tbl_excludes, vim.bo.ft) then
            return
        end

        -- restore last cursor location
        local m = api.nvim_buf_get_mark(0, '"')
        if m[1] > 0 and m[1] <= api.nvim_buf_line_count(0) then
            pcall(api.nvim_win_set_cursor, 0, m)
        end
    end,
})

autocmd("BufNewFile", {
    group = "global",
    callback = function()
        autocmd("BufWritePre", {
            group = "global",
            buffer = 0,
            once = true,
            callback = function(ev)
                -- ignore uri pattern
                if ev.match:match([[^%w://]]) then
                    return
                end

                local f = vim.uv.fs_realpath(ev.match) or ev.match
                local dir = vim.fn.fnamemodify(f, ":p:h")
                vim.fn.mkdir(dir, "p")
            end,
        })
    end,
})

--- [keymap] ---
-- center search result
keymap("n", "n", "nzzzv")
keymap("n", "N", "Nzzzv")
keymap("n", "*", "*zzzv")
keymap("n", "#", "#zzzv")

-- join line without moving cursors
keymap("n", "J", "mzJ`z")
keymap("n", "gJ", "mzgJ`z")

keymap("x", "<", "<gv")
keymap("x", ">", ">gv")

do -- https://github.com/mhinz/vim-galore#saner-command-line-history
    local nav_hist = function(key, fallback)
        return function()
            local wmmode = vim.fn.wildmenumode() == 1
            return wmmode and key or fallback
        end
    end

    keymap("c", "<c-p>", nav_hist("<c-p>", "<up>"), { expr = true })
    keymap("c", "<c-n>", nav_hist("<c-n>", "<down>"), { expr = true })
end

--- [plugins] ---
vim.cmd([[packadd! cfilter]])
vim.cmd([[packadd! termdebug]])
vim.cmd([[colorscheme retrobox]])
