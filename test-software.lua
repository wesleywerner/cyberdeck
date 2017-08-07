luaunit = require('luaunit')
software = require('software')

TestSoftware = {}

function TestSoftware:testType()
  local sw = software("Attack", 1)
  luaunit.assertEquals(sw:getType(), software.types['Attack'])
end

function TestSoftware:testRating()
  local sw = software("Attack", 1)
  luaunit.assertEquals(sw:getRating(), 1)
end

function TestSoftware:testName()
  local sw = software("Attack", 3)
  luaunit.assertEquals(sw:getName(), software.types["Attack"].names[3])
end

function TestSoftware:testText()
  local sw = software("Virus", 4)
  luaunit.assertEquals(sw:getText(), "Arsenic (Virus 4)")
end

function TestSoftware:testPrice()
  local sw1 = software("Attack", 1)
  luaunit.assertEquals(sw1:getPrice(), 50)  -- 2 * 1^2 * 25
  local sw2 = software("Attack", 3)
  luaunit.assertEquals(sw2:getPrice(), 450) -- 2 * 3^2 * 25
  local sw3 = software("Virus", 3)
  luaunit.assertEquals(sw3:getPrice(), 675) -- 3 * 3^2 * 25
end

function TestSoftware:testMemoryUsage()
  local attackSoftware = software("Attack", 1)
  luaunit.assertEquals(attackSoftware:getMemoryUsage(), 2)
  local sw = software("Virus", 2)
  luaunit.assertEquals(sw:getMemoryUsage(), 6)
end

function TestSoftware:testLoadTimeInHighSpeedNode()
  local sw = software("Attack", 1)
  local testNode = {
    isActivated = function() return true end,
    isHighSpeed = function() return true end
    }
  luaunit.assertEquals( sw:getLoadTime(testNode, nil), 1)
end

function TestSoftware:testLoadTimeWithHardware()
  local sw = software("Virus", 2)  -- gives 6 memory points
  local testNode = {
    isActivated = function() return false end,
    isHighSpeed = function() return false end
    }
  local testHardware = {
    getBandwidthRate = function() return 2 end
  }
  luaunit.assertEquals( sw:getLoadTime(testNode, testHardware), 2.25)
end

-- allow stand-alone test
if not IS_TESTING_ALL then
  os.exit( luaunit.LuaUnit.run() )
end
