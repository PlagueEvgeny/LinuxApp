vim.opt.termguicolors = true

function SetColor(color)
    color = color or "github_dark"  -- светлая тема по умолчанию
    vim.cmd.colorscheme(color)
    
    -- Для светлой темы используем светлые фоны
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "ColorColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
end

SetColor()
