require'nvim-treesitter.configs'.setup {
  ensure_installed = { "python", "lua", "sql", "cpp", "bash", "dockerfile", "css", "html", "json", "javascript" },

  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
  },
}
