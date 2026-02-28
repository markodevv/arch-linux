--require("lsp_settings")

-- TODO --
-- [x] Running project
-- [x] Running project trough debugger
-- [x] Fix quickfix error output (everything is 1 line)
-- [x] Fail build on link errors
-- [ ] Displaying output from running app
-- [x] Don't build if building process already started
-- [x] Setting/Jumping to mark
-- [x] Grep project
-- [x] Make completion prioritize closer words
-- [ ] Make completion work on improted packages
-- [x] Comment/Uncomment
-- [x] Replace in range
-- [ ] Replace in file
-- [ ] Query replace
-- [x] Goto file in current buffer directory

-- Package manager setup --

vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
  use 'neovim/nvim-lspconfig'
  use 'wbthomason/packer.nvim'
  use "ray-x/lsp_signature.nvim"
  use "Tetralux/odin.vim"
end);

------------------
vim.g.zig_fmt_autosave = 0
vim.g.zig_recommended_style = 0
--vim.g.termguicolors = false

-- Plugin configs --

local lspconfig = require("lspconfig")

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap=true, silent=true }
--vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
--vim.keymap.set('n', '<space>q', vim.diagnostic.goto_prev, opts)
--vim.keymap.set('n', '<space>e', vim.diagnostic.goto_next, opts)
--vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable lsp signature plugin
  require "lsp_signature".on_attach({
    bind = true,
    floating_window = true, 
    wrap = true,
    hint_enable = false,
    floating_window_off_y = 0,
    handler_opts = {
      border = "rounded"
    },
  }, bufnr)

  -- Disable syntax highlight provided by lsp
  client.server_capabilities.semanticTokensProvider = nil

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  --vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  --vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  --vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  --vim.keymap.set('n', '<space>wl', function()
    --print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  --end, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, bufopts)
  --vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  --vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
  --
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

require'lspconfig'.ols.setup{
  on_attach = on_attach,
  flags = lsp_flags,
}

require'lspconfig'.zls.setup{
  on_attach = on_attach,
  flags = lsp_flags,
}

require'lspconfig'.ccls.setup{
  on_attach = on_attach,
  flags = lsp_flags,
}
require'lspconfig'.ccls.setup{
  on_attach = on_attach,
  flags = lsp_flags,
}

-- Disable anoying diagnostics
vim.diagnostic.disable();

--require('lspconfig')['clangd'].setup{
--  on_attach = on_attach,
--  flags = lsp_flags,
--}

require"lsp_signature".setup {
  hi_parameter="IncSearch",
}

------------------

--config_file = "~/AppData/Local/nvim/init.lua<CR>"
config_file = "~/.config/nvim/init.lua<CR>"

-- Options --

if vim.g.neovide then
  vim.o.guifont = "Liberation Mono:h10" 
  vim.g.neovide_transparency = 1.0
  vim.g.neovide_hide_mouse_when_typing = true
  --vim.g.neovide_refresh_rate= 30 
  vim.g.neovide_refresh_rate_idle = 5
  vim.g.neovide_scroll_animation_length = 0.1
  vim.g.neovide_profiler = false
  vim.g.neovide_fullscreen = false
  vim.g.neovide_touch_drag_timeout = 0.17
  vim.g.neovide_cursor_animation_length= 0.01
  vim.g.neovide_cursor_trail_size = 0.2
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.o.completeopt="menu"
vim.o.signcolumn="no"
vim.opt.complete = '.,w,b'
vim.opt.pumheight = 8 
vim.opt.relativenumber = false
vim.opt.gdefault = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.env.HOME .. "/.undodir"
vim.opt.hlsearch = false
vim.opt.scrolloff = 8
vim.opt.cmdheight = 1
vim.cmd.colorscheme("black");
vim.filetype.add({
  pattern = {
    [".*/*vs.hlsl"] = "c",
    [".*/*fs.hlsl"] = "c",
    [".*/*hlsli"] = "c",
  }
})

------------------

-- Variables --

local qf_window_open = false
local qf_prev_win;

local build_cmd = {"py", "build.py"}
local debug_cmd
local language = "cpp"
local lang_list = {
  "odin",
  "cpp",
  "c",
  "zig",
}

local project_dir = vim.fn.getcwd();
local app_exe
local project_dir

local error_formats = 
{
  ["cpp"] = "%f(%l\\,%c): error %m", -- msbuild
  -- ["cpp"] = "%f:%l:%c: error: %m", -- clang
  ["c"] = "%f:%l:%c: error: %m", -- clang
  ["odin"] = "%f(%l:%c) Error: %m",
  ["zig"] = "%f:%l:%c: error: %m",
}

local file_greps = 
{
  ["cpp"] = "**/*.cpp **/*.h **/*.hpp **/*.c",
  ["c"] = "**/*.cpp **/*.h **/*.hpp **/*.c",
  ["odin"] = "**/*.odin **/*.hlsl **/*.hlsli",
  ["zig"] = "**/*.zig **/*.hlsl **/*.hlsli",
}

local function_regex =
{
  ["cpp"] = {"\\v^((\\w[*&]?)+\\s+){1,3}(\\w(::)?)+\\(.*", "\\v(\\w(::)?)+\\(.*"},
  ["lua"] = {"\\v^((\\w[*&]?)+\\s+){1,3}(\\w(::)?)+\\(.*", "\\v(\\w(::)?)+\\(.*"},
  ["c"] = {"\\v^((\\w[*&]?)+\\s+){1,3}(\\w(::)?)+\\(.*", "\\v(\\w(::)?)+\\(.*"},
  ["odin"] = {"\\v^(\\w+\\s+::\\s+(#\\w+\\s+){0,2}proc(\\s+\"\\w+\"\\s+)?\\()", "\\v^\\w+"},
  ["zig"] = {"\\v^(\\s*(pub\\s+)?(export\\s+)?fn\\s+\\w+\\s*\\()", "\\v^\\s*(pub\\s+)?(export\\s+)?fn\\s+\\zs\\w+"}
}


local filetype_only_complete = true;

local build_start_time;
local building_in_progress = false

local pair_map = 
{
  [string.byte("(")]  = ")" ,
  [string.byte("{")]  = "}" ,
  [string.byte("[")]  = "]" ,
  [string.byte("\"")] = "\"",
  [string.byte("\'")] = "\'",
  [string.byte("<")]  = ">" ,
}
local recording_macro = false


---------------

-- Functions --
--
local function repeat_macro()
  vim.api.nvim_feedkeys("@a", 'n', true)
end


local function record_macro()
  if recording_macro == false then
    recording_macro = true
    return "qa"
  else
    recording_macro = false
    return "q"
  end
end

local function indent_scope()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line() 
  local char = line.byte(line, pos[2]+1)

  if string.byte('{') == char then
    vim.api.nvim_feedkeys("=i{", 'n', true)
  end
  if string.byte('}') == char then
    vim.api.nvim_feedkeys("=i}", 'n', true)
  end

end


local function handle_pair(input, open, close)
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line() 
  local char = line.byte(line, pos[2]+1)
  local input_char = string.byte(input)
  local cmd = ""

  if (char == input_char) then
    cmd = vim.api.nvim_replace_termcodes("<Right>", true, false, true)
  else
    if (input == open) then
      local next_char = line.byte(line, pos[2]+2)
      if (next_char ~= string.byte(close)) then
        cmd = open .. close .. vim.api.nvim_replace_termcodes("<Left>", true, false, true)
      else
        cmd = close
      end
    else
      cmd = input
    end
  end

  vim.api.nvim_feedkeys(cmd, 'n', true)
end

local function handle_enter()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line() 
  local char = string.byte(line, pos[2])
  local next_char = string.byte(line, pos[2]+1)
  local cmd = ""

  local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true) 

  if char      == string.byte("{") and
     next_char == string.byte("}") then
    local indent = vim.api.nvim_replace_termcodes('<home>', true, false, true)
    local escape = vim.api.nvim_replace_termcodes('<esc>', true, false, true)
    local up = vim.api.nvim_replace_termcodes("<up>", true, false, true) 
    cmd = cr .. cr .. up .. escape .. 'S'
  else
    cmd = cr
  end

  vim.api.nvim_feedkeys(cmd, 'n', true)
end

local function handle_open_paren() 
  handle_pair('(', '(', ')')
end

local function handle_close_paren() 
  handle_pair(')', '(', ')')
end

local function handle_open_brace() 
  handle_pair('{', '{', '}')
end

local function handle_close_brace() 
  handle_pair('}', '{', '}')
end

local function handle_open_bracket() 
  handle_pair('[', '[', ']')
end

local function handle_close_bracket() 
  handle_pair(']', '[', ']')
end

local function handle_quotes()
  handle_pair('"', '"', '"')
end

local function handle_small_quotes()
  return handle_pair('\'', '\'', '\'')
end

local function custom_complete_func(find_start, base)
  if find_start == 1 then
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    local start = col
    
    while start > 0 and string.match(string.sub(line, start, start), '[%a_]') do
      start = start - 1
    end

    return start
  else
    local max_matches = 10;
    local matches = {};
    local filetype = vim.bo.filetype;

    -- Current buffer completion
    local cur_line = vim.api.nvim_win_get_cursor(0)[1] - 1;  -- Convert to 0-based
    local total_lines = vim.api.nvim_buf_line_count(0)
    local pattern = '[^a-zA-Z0-9_](' .. base .. '[%w_]+)'
    local start_of_line_pattern = '^' .. base .. '[%w_]+'


    local up_line = cur_line;
    local down_line = cur_line + 1;

    local start_of_line_match = function(line, pattern)
      local capture = string.match(line, pattern);
      if capture then
        print(capture)
      end
      return capture;
    end

    while #matches < max_matches and (up_line >= 0  or down_line < total_lines) do
      -- Search up first
      if up_line >= 0 then
        local line = vim.api.nvim_buf_get_lines(0, up_line, up_line + 1, false)[1]

        local start_word = start_of_line_match(line, start_of_line_pattern)
        if start_word ~= nil then table.insert(matches, start_word) end

        for word in string.gmatch(line, start_of_line_pattern) do
          table.insert(matches, word);
          break;
        end

        for word in string.gmatch(line, pattern) do
          table.insert(matches, word);
          if #matches >= max_matches then
            break;
          end
        end
        up_line = up_line - 1;
      end
      -- Then search down
      if down_line < total_lines then
        local line = vim.api.nvim_buf_get_lines(0, down_line, down_line + 1, false)[1]

        local start_word = start_of_line_match(line, start_of_line_pattern)
        if start_word ~= nil then table.insert(matches, start_word) end

        for word in string.gmatch(line, pattern) do
          table.insert(matches, word);
          if #matches >= max_matches then
            break;
          end
        end
        down_line = down_line + 1;
      end
    end

    if #matches < max_matches then
      for _, win in ipairs(vim.api.nvim_list_wins()) do

        local buf = vim.api.nvim_win_get_buf(win)
        local buf_filetype = vim.api.nvim_buf_get_option(buf, "filetype")

        if filetype_only_complete == false or (buf_filetype == filetype) then
          if buf ~= vim.api.nvim_get_current_buf() then
            local win_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            for _, line in ipairs(win_lines) do

              local start_word = start_of_line_match(line, start_of_line_pattern)
              if start_word ~= nil then table.insert(matches, start_word) end

              for word in string.gmatch(line, pattern) do
                table.insert(matches, word);
                if #matches >= max_matches then
                  return matches;
                end
              end
            end
          end
        end
      end
    end

    if #matches < max_matches then
      local finished = false;
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do

        local buf_filetype = vim.api.nvim_buf_get_option(buf, "filetype")

        if filetype_only_complete == false or (buf_filetype == filetype) then
          if buf ~= vim.api.nvim_get_current_buf() then
            local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            for _, line in ipairs(buf_lines) do

              local start_word = start_of_line_match(line, start_of_line_pattern)
              if start_word ~= nil then table.insert(matches, start_word) end

              for word in string.gmatch(line, pattern) do
                table.insert(matches, word);
                if #matches >= max_matches then
                  return matches;
                end
              end
            end
          end
        end
      end
    end

    return matches;
  end
end

_G.custom_complete = custom_complete_func

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    vim.bo.completefunc = "v:lua.custom_complete"
  end,
})

local function goto_function()
  local line_count = vim.api.nvim_buf_line_count(0)
  local lines = vim.api.nvim_buf_get_lines(0, 0, line_count, false)

  local regex = function_regex[vim.bo.filetype];

  if regex == nil then
    print("Goto function for this language not supported.\n")
    return
  end

  local regex_pattern0 = vim.regex(regex[1])
  local regex_pattern1 = vim.regex(regex[2])

  local function_list = {}
  local line_number_list = {}

  local on_input = function(input)
    if input then
      for i = 1, #function_list do
        if (function_list[i] == input) then
          local line_number = line_number_list[i]
          vim.api.nvim_win_set_cursor(vim.api.nvim_get_current_win(), {line_number, 0})
          return
        end
      end
    end
  end

  get_function_list = function(input, cmd_line, cursor_pos)
    function_list = {}
    line_number_list = {}
    for i = 1, line_count do 
      if (regex_pattern0.match_str(regex_pattern0, lines[i])) then
        if (string.find(lines[i], input)) then
          local name = string.sub(lines[i], regex_pattern1.match_str(regex_pattern0, lines[i]))
          table.insert(function_list, name)
          table.insert(line_number_list, i)
        end
      end
    end
    return function_list
  end

  vim.ui.input({
    prompt = "Go To Function:",
    completion = "customlist,v:lua.get_function_list",
  }, on_input)

end

local function normalize_spaces(text)
  return text:match("^%s*(.-)%s*$"):gsub("%s+", " ")
end

local function on_build_exit(obj)
  
  vim.schedule(function() 

    local error_format = error_formats[language]

    local output_lines = vim.split(obj.stdout, "\n", {plain = true})

    local function build_done(success)
      local elapsed_ns = vim.loop.hrtime() - build_start_time; 
      local elapsed = elapsed_ns / 1000000;
      building_in_progress = false
      if success then
        print(string.format("Build SUCCESS - %.0f ms", elapsed))
      else
        print(string.format("Build FAILED - %.0f ms", elapsed))
      end
    end

    if #obj.stdout > 1 then
      vim.fn.setqflist({}, " ", {
        title = "Build",
        lines = output_lines,
        --efm = error_format,
      })
      if string.find(obj.stdout, "LINK : fatal error") or 
        string.find(obj.stdout, ": error LNK") then
        return build_done(false)
      end
    end

    local error_lines = vim.split(obj.stderr, "\n", {plain = true})
    if #obj.stderr > 1 then
      vim.fn.setqflist({}, " ", {
        title = "Build",
        lines = error_lines,
        efm = error_format,
      })
    end

    if language == "odin" and string.find(obj.stderr, "Syntax Error:") then
      return build_done(false)
    end

    -- bufnr != 0 seems like the only way to
    -- check if there are errors in the list 
    local qflist = vim.fn.getqflist()
    for i = 1, #qflist do
      if qflist[i].bufnr ~= 0 then
        return build_done(false)
      end
    end

    return build_done(true)

  end)
end

local function build_project()
  if building_in_progress then
    return
  end
  print("Building..");
  vim.fn.setqflist({})
  building_in_progress = true
  build_start_time = vim.loop.hrtime()
  vim.system(build_cmd, {text = true}, on_build_exit);
end

local function debug_project()
  print("Running");
  local temp = debug_cmd;
  table.insert(temp, 1, "-e");
  table.insert(temp, 1, "ghostty");
  vim.fn.jobstart(temp);
end

local function complete()
  if vim.fn.pumvisible() == 1 then
    return '<C-n>'
  else
    return '<C-x><C-u>'
  end
end


local function lsp_complete()
  if vim.fn.pumvisible() == 1 then
    return '<C-n>'
  else
    return '<C-x><C-o>'
  end
end

local function toggle_quickfix()
  if (qf_window_open) then
    vim.cmd(":cclose")
    qf_window_open = false;
    vim.api.nvim_set_current_win(prev_win)
  else
    prev_win = vim.api.nvim_get_current_win()
    vim.cmd(":copen")
    vim.cmd(":wincmd J")
    qf_window_open = true;
  end
end

local function move_left_no_block()
  local col = vim.fn.col('.')
  local line = vim.fn.line('.')
  if col == 1 and line > 1 then
    -- Move to the end of the previous line
    return "k$"
  end

  return "h"
end

local function custom_visual_yank()
  local mode = vim.fn.visualmode();
  if mode == "V" then
    return "y"
  end
  return move_left_no_block() .. "y";
end

local function custom_visual_cut()
  local mode = vim.fn.visualmode();
  if mode == "V" then
    return "c"
  end
  return move_left_no_block() .. "c";
end

local function custom_visual_delete()
  local mode = vim.fn.visualmode();
  if mode == "V" then
    return "d"
  end
  return move_left_no_block() .. "d";
end

local function custom_cnext()
  local qflist = vim.fn.getqflist()
  local error_count = 0;
  for i = 1, #qflist do
    -- Seems like only way to test if line is actually an error...
    if qflist[i].lnum ~= 0 then
      error_count = error_count + 1
    end

    if error_count > 1 then
      break
    end
  end

  if error_count > 1 then
    return ":cnext<CR>"
  else
    return ":crewind<CR>"
  end
end

local function mark()
  local buf = vim.api.nvim_get_current_buf()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.api.nvim_buf_set_mark(buf, "a", line, col, {})
end

local function goto_mark()
  local buf = vim.api.nvim_get_current_buf()
  local mark = vim.api.nvim_buf_get_mark(buf, "a")

  -- Jump to the mark's position
  vim.api.nvim_win_set_cursor(0, { mark[1], mark[2] })
end

local function grep_internal(directory, pattern)

  --if use_file_dir then
    --directory = get_curr_buf_directory_path()
  --end
  if patter == "" then
    print("ERROR - No search pattern for this grep.")
  end

  local on_input = function(input)
    vim.cmd("silent! vimgrep " .. "\"" .. input .. "\"" .. directory .. pattern)
  end

  vim.ui.input({
    prompt = "Project grep:",
  }, on_input)
end

local function project_grep()
  file_grep = file_greps[language]
  grep_internal("", file_grep)
end

local function grep()
  grep_internal("", "*.*")
end

local function valid_language(lang)
  for i = 0, #lang_list do
    if lang_list[i] == lang then
      return true
    end
  end
  return false
end

local function run_project()
  if app_exe == "" then 
    return 
  end

  local exe_dir = ""

  if language == "zig" then
    exe_dir = "./build/bin/"
  end

  vim.api.nvim_echo({{"Running '" .. app_exe .. "'..."}}, false, {});
  local cmd = {exe_dir .. app_exe};
  --vim.uv.spawn(exe_dir .. app_exe, {hide = false, detached = true})
  vim.fn.jobstart(cmd);
end

local function raddbg_open()
  if app_exe == "" or project_dir == "" then 
    print("Can't ope Raddbg, no project file loaded\n")
    return 
  end

  vim.uv.spawn("raddbg.exe", {
    hide = false,
    args = {"--project:" .. project_dir .. "/project.raddbg"}, 
    detached = true})
end

local function raddbg_run_project()
  if app_exe == "" or project_dir == "" then 
    return 
  end

  vim.uv.spawn("raddbg.exe", {
    hide = false,
    args = {"--ipc", "launch_and_run", }, 
    detached = true})
end

local function raddbg_add_breakpoint()
 -- `raddbg --ipc find_code_location \"c:/foo/bar/baz.c:123:1\"` `--ipc`
  local current_file = vim.fn.expand('%:p')
  local line = vim.fn.line('.')
  local col = vim.fn.col('.')
  print("add_breakpoint \"" .. current_file .. ":" .. line .. "\"")

  vim.uv.spawn("raddbg.exe", {
    hide = false,
    args = {
      "--ipc", 
      "add_breakpoint:" .. "\"" .. current_file .. ":" .. line .. "\""
      }, 
    detached = true}
    )
 
end

local function raddbg_kill_all()

  vim.uv.spawn("raddbg.exe", {
    hide = false,
    args = {
      "--project:" .. project_dir .. "/game", 
      "--ipc", 
      "kill_all"
      }, 
    detached = true}
    )
 
end

local function load_project()
  local ok, lines = pcall(vim.fn.readfile, "./project.txt")

  if ok == false then
    print("No 'project.txt' found.")
    return
  end

  project_dir = vim.fn.getcwd();
  build_cmd = {};
  debug_cmd = {};

  for i = 1, #lines do
    local parts = vim.split(lines[i], "%s+", {trimempty = true})
    if #parts > 1 then
      if parts[1] == "language" then
        if valid_language(parts[2]) then
          language = table.concat(parts, " ", 2);
        end
      elseif parts[1] == "app_exe" then
        app_exe = table.concat(parts, " ", 2);
      elseif parts[1] == "build_cmd" then
        for j = 2, #parts do
          build_cmd[j-1] = parts[j];
        end
      elseif parts[1] == "debug_cmd" then
        for j = 2, #parts do
          debug_cmd[j-1] = parts[j];
        end
      end
    end
  end

  -- Try to open todo.txt
  if vim.fn.filereadable("./todo.txt") == 1 then
    vim.cmd.edit("./todo.txt");
  end

  --raddbg_open();

  print("Loaded project settings 'project.txt'")
  print("  language    - " .. language)
  print("  app_exe     - " .. app_exe)
  print("  project_dir - " .. project_dir)
  print("  build_cmd   - " .. table.concat(build_cmd, " "))
  print("  debug_cmd   - " .. table.concat(debug_cmd, " "))
end

local function toggle_comment()
  local mode = vim.fn.mode()
  
  if mode == 'n' then
    local line = vim.api.nvim_get_current_line()
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    
    if line:match('^%s*//') then
      -- uncomment: remove the first //
      local new_line = line:gsub('//+', '', 1)
      vim.api.nvim_buf_set_lines(0, row, row + 1, false, { new_line })
    else
      -- comment: add // at start preserving indentation
      local indent, rest = line:match('^(%s*)(.*)')
      vim.api.nvim_buf_set_lines(0, row, row + 1, false, { indent .. '//' .. rest })
    end
    
  elseif mode == 'v' or mode == 'V' then
    local start_row = vim.fn.line('v') - 1
    local end_row = vim.fn.line('.') - 1
    
    -- ensure correct order
    if start_row > end_row then
      start_row, end_row = end_row, start_row
    end
    
    local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
    local empty_lines = {};
    local all_commented = true;
    
    -- check if ALL lines are commented to decide toggle direction
    for _, l in ipairs(lines) do
      if not l:match('^%s*$') then 
        if not l:match('^%s*//') then
          all_commented = false
          break
        end
      end
    end
    local new_lines = {}
    for _, line in ipairs(lines) do
      if all_commented then
        table.insert(new_lines, (line:gsub('//+', '', 1)))
      else
        local indent, rest = line:match('^(%s*)(.*)')
        if not line:match('^%s*$') then
          table.insert(new_lines, indent .. '//' .. rest)
        else
          table.insert(new_lines, line)
        end
      end
    end
    
    vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, new_lines)
    -- exit visual mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  end
end


vim.api.nvim_create_user_command("LoadProject",          load_project, {})
vim.api.nvim_create_user_command("LaunchDebugger",       raddbg_open, {})
vim.api.nvim_create_user_command("RunProject",           run_project,  {})
vim.api.nvim_create_user_command("DebugProject",         debug_project,  {})
vim.api.nvim_create_user_command("RaddbgRun",            raddbg_run_project,  {})
vim.api.nvim_create_user_command("RaddbgAddBreakpoint",  raddbg_add_breakpoint,  {})
------------------

-- Startup functions --

--vim.cmd(":cd C:/work/project_")
load_project()
vim.cmd("syntax on")

------------------

-- Key mappings --

vim.g.mapleader = " "
vim.keymap.set("n", "<A-e>", custom_cnext, {expr = true})
vim.keymap.set("n", "<A-q>", ":cprevious<CR>")
vim.keymap.set("n", "<A-j>", "<C-d>")
vim.keymap.set("n", "<A-k>", "<C-u>")
vim.keymap.set("n", "<A-w>", "<C-w>w")
vim.keymap.set("n", "<C-i>", ":b ")
vim.keymap.set("n", "<C-o>", ":e **/*")
vim.keymap.set("n", "<A-s>", ":w<CR>")
vim.keymap.set("n", "p", "P")
vim.keymap.set("n", "P", "\"+p")
vim.keymap.set("n", "<F7>", ":e " .. config_file)
vim.keymap.set("n", "R", vim.cmd.redo)
vim.keymap.set("n", "`", toggle_quickfix)
vim.keymap.set("n", "<C-f>", "*")
vim.keymap.set("n", "<A-F>", ":e %:h/**/*")
vim.keymap.set("n", "<C-n>", "<C-^>")
vim.keymap.set("n", "<A-m>", build_project)
vim.keymap.set("n", "<F5>", debug_project)
vim.keymap.set("n", "<S-F3>", grep)
vim.keymap.set("n", "m", mark)
vim.keymap.set("n", "<S-m>", goto_mark)
vim.keymap.set("n", "<F3>", project_grep)
vim.keymap.set("n", "<F4>", run_project)
vim.keymap.set("n", "<F6>", raddbg_run_project)
vim.keymap.set("n", "<F8>", raddbg_add_breakpoint)
vim.keymap.set("n", "<S-F6>", raddbg_kill_all)
vim.keymap.set("n", "<C-r>", "<C-q>");
vim.keymap.set("n", "<space>d", ":Explore<CR>")
vim.keymap.set("n", "<A-p>", goto_function)
vim.keymap.set("n", "+", indent_scope)
vim.keymap.set("n", "<C-t>", record_macro, {expr = true})
vim.keymap.set("n", "<C-.>", "@a")
vim.keymap.set("n", "<C-c>", toggle_comment)

vim.keymap.set("v", "y", custom_visual_yank, {expr = true})
vim.keymap.set("v", "c", custom_visual_cut, {expr = true})
vim.keymap.set("v", "d", custom_visual_delete, {expr = true})
vim.keymap.set("v", "s", ":s/");
vim.keymap.set("v", "Y", "\"+y")
vim.keymap.set("v", "<C-c>", toggle_comment)

vim.keymap.set("i", "<C-t>", lsp_complete, {expr = true})
vim.keymap.set("i", "<tab>", complete, {expr = true})
vim.keymap.set("i", "<C-BS>", "<C-w>")
vim.keymap.set("i", "<C-H>", "<C-w>")
vim.keymap.set("i", "(", handle_open_paren)
vim.keymap.set("i", ")", handle_close_paren)
vim.keymap.set("i", "{", handle_open_brace)
vim.keymap.set("i", "}", handle_close_brace)
vim.keymap.set("i", "[", handle_open_bracket)
vim.keymap.set("i", "]", handle_close_bracket)
vim.keymap.set("i", "<CR>", handle_enter)


------------------
