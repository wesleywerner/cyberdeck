-- test framework
luaunit = require('luaunit')

-- logic to test
hardware = require('hardware')

-- isolate tests in a table
TestHardware = {}

function TestHardware:testType()
  local hw = hardware:create("Chip Burner", 1)
  luaunit.assertEquals(hardware:getType(hw), hardware.types["Chip Burner"])
end

function TestHardware:testRating()
  local hw = hardware:create("Chip Burner", 2)
  luaunit.assertEquals(hardware:getRating(hw), 2)
end

function TestHardware:testMaxRating()
  local hw = hardware:create("Chip Burner", 1)
  luaunit.assertEquals(hardware:getMaxRating(hw), 4)
end

function TestHardware:testName()
  local hw = hardware:create("Chip Burner", 1)
  luaunit.assertEquals(hardware:getName(hw), "Chip Burner")
end

function TestHardware:testTextChipBurnerL3()
  local hw = hardware:create("Chip Burner", 3)
  luaunit.assertEquals(hardware:getText(hw), "Chip Burner (Triple Speed)")
end

function TestHardware:testTextBioMonitorL2()
  local hw = hardware:create("Bio Monitor", 2)
  luaunit.assertEquals(hardware:getText(hw), "Bio Monitor (Auto Dump)")
end

function TestHardware:testTextProximityMapper()
  local hw = hardware:create("Proximity Mapper", 1)
  luaunit.assertEquals(hardware:getText(hw), "Proximity Mapper")
end

function TestHardware:testPriceChipBurnerL1()
  local hw = hardware:create("Chip Burner", 1)
  luaunit.assertEquals(hardware:getPrice(hw), 1000)
end

function TestHardware:testPriceChipBurnerL3()
  local hw = hardware:create("Chip Burner", 3)
  luaunit.assertEquals(hardware:getPrice(hw), 4000)
end

function TestHardware:testPriceBioMonitorL4()
  local hw = hardware:create("Bio Monitor", 4)
  luaunit.assertEquals(hardware:getPrice(hw), 4000)
end

function TestHardware:testConstructorValidation()
  local func = function()
    hardware:create("Unreal item", 1)
  end
  luaunit.assertError(func)
end

-- allow stand-alone test
if not IS_TESTING_ALL then
  os.exit( luaunit.LuaUnit.run() )
end
