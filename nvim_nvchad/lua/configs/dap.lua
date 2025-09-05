local dap = require('dap')

dap.adapters.codelldb = {
  type = 'server',
  port = '${port}',
  executable = {
    -- Adjust the path as necessary
    command = 'codelldb',
    args = {'--port', '${port}'},
  }
}

dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = function()
        local args = vim.fn.input('Program arguments: ', '', 'file')
        if args == '' then
            return nil
        end
        return vim.split(args, ' ')
    end,
  },
}

dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp
dap.configurations.objc = dap.configurations.cpp
dap.configurations.objcpp = dap.configurations.cpp

require('dapui').setup()
require('nvim-dap-virtual-text').setup()
