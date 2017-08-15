luaunit = require('luaunit')
software = require('software')

TestSoftware = {}

function TestSoftware:testType()
  local sw = software:create("Attack", 1)
  luaunit.assertEquals(software:getType(sw), software.types['Attack'])
end

function TestSoftware:testRating()
  local sw = software:create("Attack", 1)
  luaunit.assertEquals(software:getRating(sw), 1)
end

function TestSoftware:testDefaultName()
  local sw = software:create("Attack", 3)
  luaunit.assertEquals(software:getDefaultName(sw), software.types["Attack"].names[3])
end

function TestSoftware:testCustomName()
  local sw = software:create("Attack", 3, "Fritz 42")
  luaunit.assertEquals(sw.name, "Fritz 42")
end

function TestSoftware:testText()
  local sw = software:create("Virus", 4)
  luaunit.assertEquals(software:getText(sw), "Arsenic (Virus 4)")
end

function TestSoftware:testPrice()
  local sw1 = software:create("Attack", 1)
  luaunit.assertEquals(software:getPrice(sw1), 50)  -- 2 * 1^2 * 25
  local sw2 = software:create("Attack", 3)
  luaunit.assertEquals(software:getPrice(sw2), 450) -- 2 * 3^2 * 25
  local sw3 = software:create("Virus", 3)
  luaunit.assertEquals(software:getPrice(sw3), 675) -- 3 * 3^2 * 25
end

function TestSoftware:testMemoryUsage()
  local attackSoftware = software:create("Attack", 1)
  luaunit.assertEquals(software:getMemoryUsage(attackSoftware), 2)
  local virusSoftware = software:create("Virus", 2)
  luaunit.assertEquals(software:getMemoryUsage(virusSoftware), 6)
end

function TestSoftware:testLoadTimeInHighSpeedNode()
  local sw = software:create("Attack", 1)
  local testNode = {
    isActivated = function() return true end,
    isHighSpeed = function() return true end
    }
  luaunit.assertEquals(software:getLoadTime(sw, testNode, nil), 1)
end

function TestSoftware:testLoadTimeWithHardware()
  local sw = software:create("Virus", 2)  -- gives 6 memory points
  local testNode = {
    isActivated = function() return false end,
    isHighSpeed = function() return false end
    }
  local testHardware = {
    getBandwidthRate = function() return 2 end
  }
  luaunit.assertEquals(software:getLoadTime(sw, testNode, testHardware), 2.25)
end

function TestSoftware:testConstructorValidation()
  local func = function()
    software:create("Unreal Item", 1)
  end
  luaunit.assertError(func)
end

-- allow stand-alone test
if not IS_TESTING_ALL then
  os.exit( luaunit.LuaUnit.run() )
end
