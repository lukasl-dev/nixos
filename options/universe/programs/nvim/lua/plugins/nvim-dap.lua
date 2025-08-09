local dependencies = {
  "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio", "rcarriga/nvim-dap-ui",
}

--- @type table<integer, table<string, string>>
local tensor_shapes = {}

--- @param shape string
local function format_tensor_shape(shape)
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
  -- TODO: support tensor lists, tuples, dicts, ...

  if not tensor_shapes[stackframe.line] then
    tensor_shapes[stackframe.line] = {}
  end

  if tensor_shapes[stackframe.line][variable.name] then
    local value = tensor_shapes[stackframe.line][variable.name]
    if options.virt_text_pos == 'inline' then
      return " : " .. value:gsub("%s+", " ")
    else
      return variable.name .. " : " .. value:gsub("%s+", " ")
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
        tensor_shapes[stackframe.line][variable.name] = format_tensor_shape(child.value)
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
      --- @param variable dap.Variable
      --- @param buf number
      --- @param stackframe dap.StackFrame
      --- @param node userdata
      --- @param options nvim_dap_virtual_text_options
      --- @return string|nil
      display_callback = function(variable, buf, stackframe, node, options)
        if variable.type == "Tensor" then
          return display_tensor(variable, buf, stackframe, node, options)
        end

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
  },

  {
    "leoluz/nvim-dap-go",
    dependencies = dependencies,

    ft = "go",

    opts = {}
  }
}
