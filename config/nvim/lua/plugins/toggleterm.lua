require("toggleterm").setup{
  size = 20,
  open_mapping = [[<c-\>]],
  direction = 'float',
  shell = "zsh"
}

function _G.set_terminal_keymaps()
    local opts = {buffer = 0}
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- Функция для запуска текущего Python-файла в терминале
function _RunPython()
  local term = require("toggleterm.terminal").Terminal:new({
    cmd = "python3 " .. vim.fn.expand("%"),
    hidden = false,
    close_on_exit = false,
    direction = 'float'
  })
  print("Запуск команды: python3 " .. vim.fn.expand("%"))

  term:toggle()
end

-- Назначение сочетания клавиш, например, <Leader>r
vim.api.nvim_set_keymap('n', '<Leader>r', ':lua _RunPython()<CR>', { noremap = true, silent = true })


vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
