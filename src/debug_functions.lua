
-- print system area map to console
function debug_print_system()
  -- best guess of map size to print
  local some_size = 8
  -- node type name lookup
  local NT_NAMES = {
    [NT_CPU] = "u",
    [NT_SPU] = "s",
    [NT_COP] = "c",
    [NT_DS] = "d",
    [NT_IO] = "i",
    [NT_JUNC] = "j",
    [NT_PORTAL_IN] = "e",
    [NT_PORTAL_OUT] = "o"
  }
  for i, area in ipairs(system.areas) do
    print('AREA '..i)
    print('----------------------------')
    for y = -some_size, some_size do
      for x = -some_size, some_size do
        local _node_idx = area.map[tostr(x)..tostr(y)]
        if _node_idx then
          local node = area.nodes[_node_idx]
          io.write(NT_NAMES[node.NT] or "?")
          -- io.write(tostr(node.NT))
          io.write(" ")
        else
          io.write("  ")
        end
      end
      -- end of row
      io.write("\n")
    end
  end
end