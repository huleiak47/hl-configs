-- the clangd installed by mason will report error like:
-- "Configuration file(s) do(es) not support C: D:\\projects\\xxx\\.clang-format. Fallback is LLVM style."
-- and cannot format code as expect.
-- So we use clangd local, you should insall the correct clangd.
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      clangd = {
        mason = false,
      },
      pyright = {
        mason = false,
      },
      ruff = {
        mason = false,
      },
    },
  },
}
