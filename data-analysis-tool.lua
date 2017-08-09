local ice = require("ice")

local function strpad(input, pad_length, pad_string, pad_type)
  if not input then return "" end
  local output = input

  if not pad_string then pad_string = ' ' end
  if not pad_type   then pad_type   = 'STR_PAD_RIGHT' end

  if pad_type == 'STR_PAD_BOTH' then
    local j = 0
    while string.len(output) < pad_length do
      output = j % 2 == 0 and output .. pad_string or pad_string .. output
      j = j + 1
    end
  else
    while string.len(output) < pad_length do
      output = pad_type == 'STR_PAD_LEFT' and pad_string .. output or output .. pad_string
    end
  end

  return output
end

function printIceTypes()
  print("\n# Listing of all ICE types #")
  print(strpad("TYPE NAME",20) .. strpad("FLAGS",20))
  for iceKey,iceValue in pairs(ice.types) do
    
    -- collect flag keys
    local flagNames=nil
    if iceValue.allowedFlags then
      local flagKeyList={}
      for flagKey,flagValue in pairs(iceValue.allowedFlags) do
        table.insert(flagKeyList, flagValue)
      end
      flagNames = table.concat(flagKeyList, ",")
    end
    
    print("* " .. strpad(iceKey,18) .. strpad(flagNames,20))
    
  end
end



printIceTypes()
