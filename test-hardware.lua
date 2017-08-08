-- test framework
luaunit = require('luaunit')

-- logic to test
hardware = require('hardware')

-- isolate tests in a table
TestHardware = {}

function TestHardware:testType()
  local hw = hardware("Chip Burner", 1)
  luaunit.assertEquals(hw:getType(), hardware.types["Chip Burner"])
end

function TestHardware:testRating()
  local hw = hardware("Chip Burner", 2)
  luaunit.assertEquals(hw:getRating(), 2)
end

function TestHardware:testMaxRating()
  local hw = hardware("Chip Burner", 1)
  luaunit.assertEquals(hw:getMaxRating(), 4)
end

function TestHardware:testName()
  local hw = hardware("Chip Burner", 1)
  luaunit.assertEquals(hw:getName(), "Chip Burner")
end

function TestHardware:testTextChipBurnerL3()
  local hw = hardware("Chip Burner", 3)
  luaunit.assertEquals(hw:getText(), "Chip Burner (Triple Speed)")
end

function TestHardware:testTextBioMonitorL2()
  local hw = hardware("Bio Monitor", 2)
  luaunit.assertEquals(hw:getText(), "Bio Monitor (Auto Dump)")
end

function TestHardware:testTextProximityMapper()
  local hw = hardware("Proximity Mapper", 1)
  luaunit.assertEquals(hw:getText(), "Proximity Mapper")
end

function TestHardware:testPriceChipBurnerL1()
  local hw = hardware("Chip Burner", 1)
  luaunit.assertEquals(hw:getPrice(), 1000)
end

function TestHardware:testPriceChipBurnerL3()
  local hw = hardware("Chip Burner", 3)
  luaunit.assertEquals(hw:getPrice(), 4000)
end

function TestHardware:testPriceBioMonitorL4()
  local hw = hardware("Bio Monitor", 4)
  luaunit.assertEquals(hw:getPrice(), 4000)
end

function TestHardware:testConstructorValidation()
  local func = function()
    hardware("Unreal item", 1)
  end
  luaunit.assertError(func)
end

-- allow stand-alone test
if not IS_TESTING_ALL then
  os.exit( luaunit.LuaUnit.run() )
end
