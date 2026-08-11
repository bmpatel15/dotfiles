-- 2 spaces is the prevailing Bash convention (Google shell style guide, and
-- what shfmt assumes). The global default of 4 is a Python habit.
-- conform passes this width to shfmt as -i, so formatting matches the buffer.
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true

vim.opt_local.colorcolumn = "100"
