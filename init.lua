local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "

local map = vim.keymap.set

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },

  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        default_component_configs = {
          icon = {
            folder_closed = "",
            folder_open = "",
            folder_empty = "",
            default = "*",
          },
        },
        filesystem = {
          filtered_items = {
            visible = true,
          },
          window = {
            mappings = {
              ["a"] = "add",
              ["A"] = "add_directory",
              ["d"] = "delete",
              ["r"] = "rename",
            },
          },
        },
      })

      map("n", "<leader>x", "<cmd>Neotree filesystem reveal left<CR>", {
        silent = true,
        desc = "File tree",
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "javascript",
          "typescript",
          "python",
          "html",
          "css",
          "c",
          "cpp",
          "markdown",
          "markdown_inline",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("render-markdown").setup({})
    end,
  },

  {
    "hrsh7th/cmp-nvim-lsp",
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "windwp/nvim-autopairs",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      })
    end,
  },

  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "pyright",
          "html",
          "ts_ls",
          "clangd",
        },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
      })

      vim.lsp.config("pyright", {
        capabilities = capabilities,
      })

      vim.lsp.config("html", {
        capabilities = capabilities,
      })

      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
      })

      vim.lsp.config("clangd", {
        capabilities = capabilities,
      })

      vim.lsp.enable("lua_ls")
      vim.lsp.enable("pyright")
      vim.lsp.enable("html")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("clangd")

      map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
      map("n", "gr", vim.lsp.buf.references, { desc = "References" })
      map("n", "<leader>d", vim.lsp.buf.definition, { desc = "Definition" })
      map("n", "<leader>a", vim.lsp.buf.code_action, { desc = "Code action" })
      map("n", "<leader>h", vim.lsp.buf.hover, { desc = "Hover" })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          section_separators = "",
          component_separators = "",
        },
      })
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup({})
    end,
  },
})

local builtin = require("telescope.builtin")

local function system_open(target)
  if vim.ui and vim.ui.open then
    local ok = pcall(vim.ui.open, target)
    if ok then
      return true
    end
  end

  local uname = vim.loop.os_uname().sysname

  if uname == "Darwin" then
    vim.fn.jobstart({ "open", target }, { detach = true })
    return true
  elseif uname == "Linux" then
    vim.fn.jobstart({ "xdg-open", target }, { detach = true })
    return true
  elseif uname:match("Windows") then
    vim.fn.jobstart({ "cmd", "/c", "start", "", target }, { detach = true })
    return true
  end

  return false
end

local function file_exists(path)
  return vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1
end

local function is_absolute_path(path)
  if not path or path == "" then
    return false
  end

  if path:match("^/") then
    return true
  end

  if path:match("^%a:[/\\]") then
    return true
  end

  if path:match("^\\\\") then
    return true
  end

  return false
end

local function case_insensitive_resolve(path)
  if file_exists(path) then
    return path
  end

  local dir = vim.fn.fnamemodify(path, ":h")
  local name = vim.fn.fnamemodify(path, ":t")

  if vim.fn.isdirectory(dir) == 0 then
    return nil
  end

  local entries = vim.fn.readdir(dir)
  for _, entry in ipairs(entries) do
    if entry:lower() == name:lower() then
      local fixed = dir .. "/" .. entry
      if file_exists(fixed) then
        return fixed
      end
    end
  end

  return nil
end

local function normalize_path(path)
  if not path or path == "" then
    return nil, false
  end

  path = vim.trim(path)

  if (path:sub(1, 1) == '"' and path:sub(-1) == '"')
    or (path:sub(1, 1) == "'" and path:sub(-1) == "'")
  then
    path = path:sub(2, -2)
  end

  local lower = path:lower()
  if lower:match("^https?://") or lower:match("^file://") then
    return path, true
  end

  path = vim.fn.expand(path)

  if not is_absolute_path(path) then
    local cwd = vim.fn.getcwd()
    path = vim.fn.fnamemodify(cwd .. "/" .. path, ":p")
  else
    path = vim.fn.fnamemodify(path, ":p")
  end

  path = vim.fn.simplify(path)

  if file_exists(path) then
    return path, false
  end

  local fixed = case_insensitive_resolve(path)
  if fixed then
    return fixed, false
  end

  return path, false
end

local function extract_markdown_path(line, col)
  local patterns = {
    "!%b[]%((.-)%)",
    "%b[]%((.-)%)",
    "<(.-)>",
  }

  for _, pattern in ipairs(patterns) do
    local start_from = 1
    while true do
      local s, e, match = line:find(pattern, start_from)
      if not s then
        break
      end

      if col >= s and col <= e then
        return match
      end

      start_from = e + 1
    end
  end

  return nil
end

local function open_path_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1

  local raw_path = extract_markdown_path(line, col) or vim.fn.expand("<cfile>")

  if not raw_path or raw_path == "" then
    print("No path found under cursor")
    return
  end

  local path, is_uri = normalize_path(raw_path)

  if not path then
    print("Could not resolve path")
    return
  end

  if not is_uri and not file_exists(path) then
    print("Path does not exist: " .. path)
    return
  end

  local ok = system_open(path)
  if not ok then
    print("Could not open path on this system")
  end
end

local function open_term_and_run(cmd)
  vim.cmd("belowright split")
  vim.cmd("resize 12")
  vim.cmd("terminal " .. cmd)
  vim.cmd("startinsert")
end

local function run_current_file()
  local file = vim.fn.expand("%:p")
  local file_no_ext = vim.fn.expand("%:p:r")
  local ft = vim.bo.filetype

  if file == "" then
    print("No file to run")
    return
  end

  vim.cmd("write")

  if ft == "python" then
    open_term_and_run("python3 " .. vim.fn.shellescape(file))
  elseif ft == "javascript" then
    open_term_and_run("node " .. vim.fn.shellescape(file))
  elseif ft == "sh" or ft == "bash" then
    open_term_and_run("bash " .. vim.fn.shellescape(file))
  elseif ft == "lua" then
    open_term_and_run("lua " .. vim.fn.shellescape(file))
  elseif ft == "c" then
    local out = vim.fn.shellescape(file_no_ext)
    open_term_and_run(
      "gcc " .. vim.fn.shellescape(file) .. " -o " .. out .. " && " .. out
    )
  elseif ft == "cpp" then
    local out = vim.fn.shellescape(file_no_ext)
    open_term_and_run(
      "g++ " .. vim.fn.shellescape(file) .. " -std=c++17 -o " .. out .. " && " .. out
    )
  elseif ft == "html" then
    local ok = system_open(file)
    if ok then
      print("Opened HTML in browser")
    else
      print("Could not open HTML file")
    end
  else
    print("No run action configured for filetype: " .. ft)
  end
end

map("n", "<leader>f", builtin.find_files, { desc = "Find files" })
map("n", "<leader>g", builtin.live_grep, { desc = "Live grep" })
map("n", "<leader>r", run_current_file, { desc = "Run current file" })
map("n", "<leader>o", open_path_under_cursor, { desc = "Open path under cursor" })
map("n", "gx", open_path_under_cursor, { desc = "Open path under cursor" })

vim.opt.number = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

require("catppuccin").setup({
  flavour = "mocha",
})

vim.cmd.colorscheme("catppuccin")