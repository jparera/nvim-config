vim.opt.termguicolors = true

if vim.g.colors_name then
    vim.cmd('hi clear')
end

vim.g.colors_name = "rose-pine-wrlt"

local variants = {
    dark = {
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
    CurSearch = { bg = palette.highlight_high },
    Cursor = { bg = palette.muted },
    CursorLine = {},
    CursorLineNr = { bg = palette.overlay },
    ErrorMsg = { bg = palette.love },
    FloatBorder = { link = 'NormalFloat', },
    FloatTitle = { link = 'NormalFloat' },
    Folded = { fg = palette.muted },
    FoldColumn = { bg = palette.surface },
    LineNr = { fg = palette.muted, bg = palette.surface },
    ModeMsg = { fg = palette.pine },
    MsgArea = { bg = palette.overlay },
    MoreMsg = { fg = palette.foam },
    NonText = { fg = palette.iris },
    Normal = { fg = palette.text, bg = palette.base },
    NormalFloat = { bg = palette.overlay },
    NormalNC = { fg = palette.muted },
    MatchParen = { fg = palette.love },
    Question = { fg = palette.foam },
    QuickFixLine = { fg = palette.foam },
    Search = { fg = palette.base, bg = palette.rose },
    SignColumn = { bg = palette.surface },
    SpecialKey = { fg = palette.muted },
    SpellBad = { fg = palette.love, undercurl = true },
    SpellCap = { fg = palette.gold, undercurl = true },
    SpellLocal = { fg = palette.gold, undercurl = true },
    SpellRare = { fg = palette.gold, undercurl = true },
    StatusLine = { bg = palette.surface },
    StatusLineNC = { fg = palette.muted, bg = palette.surface },
    Visual = { bg = palette.highlight_med },
    Title = { bold = true },
    WarningMsg = { fg = palette.gold },
    WinBar = {},
    WinBarNC = {},
    WinSeparator = { fg = palette.highlight_high },
    Whitespace = { fg = palette.iris },

    Added = { fg = palette.foam },
    Changed = { fg = palette.rose },
    Constant = { fg = palette.gold },
    Comment = { fg = palette.muted },
    Delimiter = { fg = palette.subtle },
    DiagnosticDeprecated = { fg = palette.gold, strikethrough = true },
    DiagnosticError = { fg = palette.love },
    DiagnosticHint = { fg = palette.iris },
    DiagnosticInfo = { fg = palette.foam },
    DiagnosticOk = { fg = palette.pine },
    DiagnosticUnderlineError = { fg = palette.love, underline = true },
    DiagnosticUnderlineHint = { fg = palette.iris, underline = true },
    DiagnosticUnderlineInfo = { fg = palette.foam, underline = true },
    DiagnosticUnderlineOk = { fg = palette.pine, underline = true },
    DiagnosticUnderlineWarn = { fg = palette.gold, underline = true },
    DiagnosticUnnecessary = { fg = palette.rose },
    DiagnosticWarn = { fg = palette.gold },
    DiffAdd = { fg = palette.foam },
    DiffChange = { fg = palette.rose },
    DiffDelete = { fg = palette.love },
    Error = { fg = palette.love },
    Function = { fg = palette.rose },
    Keyword = { fg = palette.pine },
    Operator = { fg = palette.subtle },
    PreProc = { fg = palette.iris, italic = true },
    Removed = { fg = palette.love },
    String = { fg = palette.gold },
    Special = { link = 'Keyword' },
    Statement = { fg = palette.iris },
    Type = { fg = palette.foam, nocombine = true },

    TelescopeNormal = { link = 'NormalFloat' },
    TelescopePromptNormal = { link = 'NormalFloat' },
    TelescopeMatching = { bold = true },

    ['@constructor'] = { link = 'Function' },
    ['@variable'] = {},
    ['@variable.member'] = { italic = true, bold = true },
    ['@variable.builtin'] = { fg = palette.love },
    ['@variable.parameter'] = { fg = palette.iris },
    ['@function.builtin'] = { fg = palette.love },
    ['@type.builtin'] = { link = 'Type' },
    ['@spell'] = {},

    ['@lsp.type.annotation'] = { link = '@attribute' },
    ['@lsp.type.modifier'] = { link = 'Keyword' },
    ['@lsp.type.property'] = { link = '@variable.member' },
    ['@lsp.mod.global'] = { fg = palette.love, bold = true },
    ['@lsp.typemod.function.defaultLibrary'] = { link = '@function.builtin' },
    ['@lsp.typemod.variable.declaration'] = { link = '@variable' }
}

for group, highlight in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, highlight)
end
