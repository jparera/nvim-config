vim.opt.termguicolors = true

if vim.g.colors_name then
    vim.cmd('hi clear')
end

vim.g.colors_name = "rose-pine-wrlt"

local variants = {
    dark = {
        _nc = "#16141f",
        base = "#191724",
        surface = "#1f1d2e",
        overlay = "#26233a",
        muted = "#6e6a86",
        subtle = "#908caa",
        text = "#e0def4",
        love = "#eb6f92",
        gold = "#f6c177",
        rose = "#ebbcba",
        pine = "#31748f",
        foam = "#9ccfd8",
        iris = "#c4a7e7",
        highlight_low = "#21202e",
        highlight_med = "#403d52",
        highlight_high = "#524f67",
        none = "NONE",
    },
    light = {
        _nc = "#f8f0e7",
        base = "#faf4ed",
        surface = "#fffaf3",
        overlay = "#f2e9e1",
        muted = "#9893a5",
        subtle = "#797593",
        text = "#575279",
        love = "#b4637a",
        gold = "#ea9d34",
        rose = "#d7827e",
        pine = "#286983",
        foam = "#56949f",
        iris = "#907aa9",
        highlight_low = "#f4ede8",
        highlight_med = "#dfdad9",
        highlight_high = "#cecacd",
        none = "NONE",
    },
}

local palette = variants[vim.o.background]
local highlights = {
    -- Build-in highlighting groups
    ColorColumn = { bg = palette.surface },
    CursorLine = {},
    CursorLineNr = { fg = palette.text, bold = true },
    LineNr = { fg = palette.muted },
    Normal = { fg = palette.text, bg = palette.base },
    NormalNC = { fg = palette.muted, bg = palette._nc },
    MatchParen = { bg = palette.highlight_high, bold = true },
    StatusLine = { fg = palette.subtle, bg = palette.surface },
    StatusLineNC = { fg = palette.muted, bg = palette._nc },

    Constant = { fg = palette.gold },
    Comment = { fg = palette.muted },
    Delimiter = { fg = palette.subtle },
    Function = { fg = palette.rose },
    Keyword = { fg = palette.pine },
    Operator = { fg = palette.subtle },
    String = { fg = palette.gold },
    Special = { link = 'Keyword' },
    Type = { fg = palette.foam },

    ['@variable'] = { fg = palette.text },
    ['@variable.member'] = { italic = true, bold = true },
    ['@variable.parameter'] = { fg = palette.iris },

    ['@lsp.type.modifier'] = { link = 'Keyword' },
    ['@lsp.type.property'] = { link = '@variable.member' },
    ['@lsp.mod.global'] = { bold = true },
}

for group, highlight in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, highlight)
end
