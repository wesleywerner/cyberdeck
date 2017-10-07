describe("Software", function()

  local software = require('software')

  it("get the type definition", function()
    local sw = software:create("Attack", 1)
    local expected = software:getType("Attack")
    assert.are.same(expected, software:getType(sw.class))
  end)

  it("get the potential rating", function()
    local sw = software:create("Attack", 4)
    assert.are.equals(4, software:getPotentialRating(sw))
  end)

  it("get the active rating", function()
    -- to test the active rating we must load the software first and
    -- then update it to forward it's load progress.
    local sw = software:create("Virus", 2)

    -- ensure the software can be loaded
    local canwe = software:canLoad(sw)
    assert.is_true(canwe)

    -- assume a high-speed node, which has a load time of 1
    local bandwidthrate = 2
    local highspeednode = false

    -- load it
    software:beginLoad(sw, highspeednode, bandwidthrate)

    -- test the expected load turns
    assert.are.equal(2, sw.loadTurns)

    -- check it is in a loading state
    local isloading = software:isLoading(sw)
    assert.is_true(isloading)

    -- call update twice, simulating 2 turns, to forward the loading process
    software:update(sw)
    software:update(sw)

    -- now we can get the rating
    assert.are.equals(2, software:getActiveRating(sw))

  end)

  it("get the default name", function()
    local sw = software:create("Attack", 3)
    local expected = software:getType("Attack")
    assert.are.equals(expected.names[3], software:getDefaultName(sw))
  end)

  it("get the custom name", function()
    local sw = software:create("Attack", 3, "Fritz 42")
    assert.are.equals("Fritz 42", sw.name)
  end)

  it("get the descriptive text", function()
    local sw = software:create("Virus", 4)
    assert.are.equals("Arsenic (Virus 4)", software:getText(sw))
  end)

  it("get the price for L1 attack", function()
    local sw1 = software:create("Attack", 1)
    assert.are.equals(50, software:getPrice(sw1))  -- 2 * 1^2 * 25
  end)

  it("get the price for L3 attack", function()
    local sw2 = software:create("Attack", 3)
    assert.are.equals(450, software:getPrice(sw2)) -- 2 * 3^2 * 25
  end)

  it("get the price for L3 virus", function()
    local sw3 = software:create("Virus", 3)
    assert.are.equals(675, software:getPrice(sw3)) -- 3 * 3^2 * 25
  end)

  it("get the memory usage for L1 attack", function()
    local attackSoftware = software:create("Attack", 1)
    assert.are.equals(2, software:getMemoryUsage(attackSoftware))
  end)

  it("get the memory usage for L2 virus", function()
    local virusSoftware = software:create("Virus", 2)
    assert.are.equals(6, software:getMemoryUsage(virusSoftware))
  end)

  it("get the load time for a high-speed node", function()
    local sw = software:create("Attack", 1)
    local highspeednode = true
    local loadtime = software:getLoadTime(sw, highspeednode)
    assert.are.equals(1, loadtime)
  end)

  it("get the load time with a bandwidth bus", function()
    local sw = software:create("Virus", 2)  -- gives 6 memory points
    local bandwidthrate = 2
    local highspeednode = false
    local loadtime = software:getLoadTime(sw, highspeednode, bandwidthrate)
    assert.are.equals(2, loadtime)
  end)

  it("get the load time with no bandwidth bus", function()
    local sw = software:create("Virus", 2)  -- gives 6 memory points
    local bandwidthrate = 0 -- gives a speed factor of 1 (ie no factor)
    local highspeednode = false
    local loadtime = software:getLoadTime(sw, highspeednode, bandwidthrate)
    assert.are.equals(6, loadtime)
  end)

  it("errors on creating an invalid software", function()
    local func = function()
      software:create("Unreal Item", 1)
    end
    assert.has.errors(func)
  end)

end)

