describe("Software", function()

  local software = require('software')

  it("get the type definition", function()
    local sw = software:create("Attack", 1)
    assert.are.equals(software:getType(sw), software.types['Attack'])
  end)

  it("get the potential rating", function()
    local sw = software:create("Attack", 4)
    assert.are.equals(software:getPotentialRating(sw), 4)
  end)

  it("get the loaded rating", function()
    -- to test the rating, which is actually the "active rating" we must
    -- load the software first
    local sw = software:create("Attack", 2)
    -- ensure the software can be loaded
    local canwe = software:canLoad(sw)
    assert.is_true(canwe)
    -- assume a high-speed node, which has a load time of 1
    local db2 = {
      player = {
        node = {
          isActivated = function() return true end,
          isHighSpeed = function() return true end
        }
      }
    }
    -- load it
    software:beginLoad(db2, sw)
    -- check it is in a loading state
    local isloading = software:isLoading(sw)
    assert.is_true(isloading)
    -- call update to forward the loading process
    software:update(sw)
    -- now we can get the rating
    assert.are.equals(software:getActiveRating(sw), 2)
  end)

  it("get the default name", function()
    local sw = software:create("Attack", 3)
    assert.are.equals(software:getDefaultName(sw), software.types["Attack"].names[3])
  end)

  it("get the custom name", function()
    local sw = software:create("Attack", 3, "Fritz 42")
    assert.are.equals(sw.name, "Fritz 42")
  end)

  it("get the descriptive text", function()
    local sw = software:create("Virus", 4)
    assert.are.equals(software:getText(sw), "Arsenic (Virus 4)")
  end)

  it("get the price for L1 attack", function()
    local sw1 = software:create("Attack", 1)
    assert.are.equals(software:getPrice(sw1), 50)  -- 2 * 1^2 * 25
  end)

  it("get the price for L3 attack", function()
    local sw2 = software:create("Attack", 3)
    assert.are.equals(software:getPrice(sw2), 450) -- 2 * 3^2 * 25
  end)

  it("get the price for L3 virus", function()
    local sw3 = software:create("Virus", 3)
    assert.are.equals(software:getPrice(sw3), 675) -- 3 * 3^2 * 25
  end)

  it("get the memory usage for L1 attack", function()
    local attackSoftware = software:create("Attack", 1)
    assert.are.equals(software:getMemoryUsage(attackSoftware), 2)
  end)

  it("get the memory usage for L2 virus", function()
    local virusSoftware = software:create("Virus", 2)
    assert.are.equals(software:getMemoryUsage(virusSoftware), 6)
  end)

  it("get the load time within a high-speed node", function()
    local sw = software:create("Attack", 1)
    local db2 = {
      player = {
        node = {
          isActivated = function() return true end,
          isHighSpeed = function() return true end
        }
      }
    }
    assert.are.equals(software:getLoadTime(db2, sw), 1)
  end)

  it("get the load time with a high-bandwidth bus", function()
    local sw = software:create("Virus", 2)  -- gives 6 memory points
    local db2 = {
      player = {
        hardware = {
          getBandwidthRate = function() return 2 end
        }
      }
    }
    assert.are.equals(software:getLoadTime(db2, sw), 2.25)
  end)

  it("errors on creating an invalid software", function()
    local func = function()
      software:create("Unreal Item", 1)
    end
    assert.has.errors(func)
  end)

end)

