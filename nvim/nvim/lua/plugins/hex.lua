return {
  "RaafatTurki/hex.nvim",
  config = function()
    require("hex").setup({

      -- cli command used to dump hex data
      dump_cmd = "xxd -g 1 -u",

      -- cli command used to assemble from hex data
      assemble_cmd = "xxd -r",
      is_file_binary_pre_read = function()
        return false
      end,

      is_file_binary_post_read = function()
        -- 采样首1KB内容进行检测
        local sample_size = 1024
        local lines = vim.api.nvim_buf_get_lines(0, 0, 1000, false)
        local content = table.concat(lines, "\n"):sub(1, sample_size)

        -- 核心检测逻辑 -------------------------------------------------
        -- 步骤1：检查是否存在Null字节（二进制文件标志）
        if content:find("\0") then
          return true
        end

        -- 步骤2：如果编码为latin1则认为是二进制文件
        if vim.bo.fileencoding == "latin1" then
          return true
        end
        return false
      end,
    })
  end,
}
