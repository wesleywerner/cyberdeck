describe("Chips", function()

  local chips = require('chips')

  it("get the type definition", function()
    local cpu = chips:create("CPU", 1)
    local expected = {
      class = "CPU",
      baseCost = 150,
      complexity = 5
    }
    assert.are.same(expected, chips:getType(cpu.class))
  end)

  it("get the rating", function()
    local cpu = chips:create("CPU", 3)
    assert.are.equals(3, chips:getRating(cpu))
  end)

  it("get the name", function()
    local cpu = chips:create("CPU", 1)
    assert.are.equals("CPU", chips:getName(cpu))
  end)

  it("get the price L1", function()
    local cpu = chips:create("CPU", 1)
    assert.are.equals(150, chips:getPrice(cpu))
  end)

  it("get the price L3", function()
    local cop = chips:create("Coprocessor", 3)
    assert.are.equals(1125, chips:getPrice(cop))
  end)

  it("get the descriptive text", function()
    local cop = chips:create("Coprocessor", 3)
    assert.are.equals("Coprocessor L3", chips:getText(cop))
  end)

  it("error when creating an invalid chip", function()
    local func = function()
      chips:create("Unreal item", 3)
    end
    assert.has.errors(func)
  end)

  it("get complexity", function()
    local cpu = chips:create("CPU", 1)
    assert.are.equals(5, chips:getComplexity(cpu))
  end)

end)
