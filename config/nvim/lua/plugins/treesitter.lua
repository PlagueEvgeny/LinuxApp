require'nvim-treesitter.configs'.setup {
  ensure_installed = { "python", "lua", "sql", "cpp", "bash", "dockerfile", "css", "html", "json", "javascript" },

  sync_install = true,
  auto_install = true,
  highlight = {
    enable = true,
  },
}
