---@type LazyKeysSpec[]
return {
  {
    "<leader>hm",
    function()
      require("harpoon.mark").add_file()
    end,
    desc = "Harpoon Mark File",
  },
  {
    "<leader>hh",
    function()
      require("harpoon.ui").toggle_quick_menu()
    end,
    desc = "Harpoon Toggle Quick Menu",
  },
  {
    "<leader>hn",
    function()
      require("harpoon.ui").nav_next()
    end,
    desc = "Harpoon Next File",
  },
  {
    "<leader>hp",
    function()
      require("harpoon.ui").nav_prev()
    end,
    desc = "Harpoon Previous File",
  },
}
