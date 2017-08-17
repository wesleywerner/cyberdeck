luaunit = require('luaunit')
software = require('software')

TestSoftware = {}

function TestSoftware:testType()
  local sw = software:create("Attack", 1)
  luaunit.assertEquals(software:getType(sw), software.types['Attack'])
end

function TestSoftware:testRating()
  -- to test the rating, which is actually the "active rating" we must
  -- load the software first
  local sw = software:create("Attack", 2)
  -- ensure the software can be loaded
  local canwe = software:canLoad(sw)
  luaunit.assertTrue(canwe)
  -- assume a high-speed node, which has a load time of 1
  local db = {
    player = {
      node = {
        isActivated = function() return true end,
        isHighSpeed = function() return true end
      }
    }
  }
  -- load it and call update to forward the loading process
  software:beginLoad(db, sw)
  -- check it is in a loading state
  local isloading = software:isLoading(sw)
  luaunit.assertTrue(isloading)
  software:update(sw)
  -- get the active rating
  luaunit.assertEquals(software:getRating(sw), 2)
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
  local db = {
    player = {
      node = {
        isActivated = function() return true end,
        isHighSpeed = function() return true end
      }
    }
  }
  luaunit.assertEquals(software:getLoadTime(db, sw), 1)
end

function TestSoftware:testLoadTimeWithHardware()
  local sw = software:create("Virus", 2)  -- gives 6 memory points
  local db = {
    player = {
      hardware = {
        getBandwidthRate = function() return 2 end
      }
    }
  }
  luaunit.assertEquals(software:getLoadTime(db, sw), 2.25)
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
