---@type LazyKeysSpec[]
return {
  { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
  { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
  { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
  { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
  { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
  {
    "<leader>dB",
    function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
    desc = "Conditional Breakpoint",
  },
  {
    "<leader>dl",
    function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end,
    desc = "Log Point",
  },
  { "<leader>dr", function() require("dap").repl.open() end, desc = "Open REPL" },
  { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
  { "<leader>dR", function() require("dap").run_last() end, desc = "Run Last" },
  { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
  {
    "<leader>de",
    function() require("dapui").eval() end,
    desc = "Evaluate Expression",
    mode = { "n", "v" },
  },
}
