local dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio", "rcarriga/nvim-dap-ui" }

--- @type table<string, string>
local tensor_shapes = {}

--- @param shape string
local function format_shape(shape)
  --- starts with torch.Size([
  local torch = "torch.Size(["
  if shape:sub(1, torch:len()) == torch then
    return "(" .. shape:sub(torch:len() + 1, -3):gsub(",", " x ") .. ")"
  end

  return shape
end

--- @param variable dap.Variable
--- @param buf number
--- @param stackframe dap.StackFrame
--- @param node userdata
--- @param options nvim_dap_virtual_text_options
--- @return string|nil
local function display_tensor(variable, buf, stackframe, node, options)
  if tensor_shapes[variable.name] then
    -- Return the cached shape if available
    if options.virt_text_pos == 'inline' then
      return " : " .. tensor_shapes[variable.name]:gsub("%s+", " ")
    else
      return variable.name .. " : " .. tensor_shapes[variable.name]:gsub("%s+", " ")
    end
  end

  --- @type dap.Session
  local session = require("dap").session()
  --- @type dap.VariablesArguments
  local args = { variablesReference = variable.variablesReference }

  --- @param err dap.ErrorResponse
  --- @param result dap.VariableResponse
  session:request("variables", args, function(err, result)
    if err then
      vim.notify("Error getting tensor shape: " .. tostring(err), vim.log.levels.ERROR)
      return
    end

    for _, child in ipairs(result.variables) do
      --- @type dap.Variable
      child = child
      if child.name == "shape" then
        tensor_shapes[variable.name] = format_shape(child.value)
      end
    end
  end)

  return ""
end

return {
  {
    "mfussenegger/nvim-dap",

    event = "BufWinEnter",
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },

    event = "BufWinEnter",

    opts = {},
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },

    event = "BufWinEnter",

    opts = {
      --- A callback that determines how a variable is displayed or whether it should be omitted
      --- @param variable dap.Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
      --- @param buf number
      --- @param stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
      --- @param node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
      --- @param options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
      --- @return string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
      display_callback = function(variable, buf, stackframe, node, options)
        if variable.type == "Tensor" then
          return display_tensor(variable, buf, stackframe, node, options)
        end

        -- Fallback for non-tensor variables
        if options.virt_text_pos == 'inline' then
          return " = " .. variable.value:gsub("%s+", " ")
        else
          return variable.name .. " = " .. variable.value:gsub("%s+", " ")
        end
      end
    },
  },

  {
    "mfussenegger/nvim-dap-python",
    dependencies = dependencies,

    ft = "python",

    config = function()
      require("dap-python").setup("uv")
    end,
  }
}
