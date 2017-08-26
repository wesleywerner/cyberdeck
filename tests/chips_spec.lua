describe("Chips", function()

  local chips = require('chips')

  it("get the type definition", function()
    local cpu = chips:create("CPU", 1)
    assert.are.equals(chips:getType(cpu), chips.types['CPU'])
  end)

  it("get the rating", function()
    local cpu = chips:create("CPU", 3)
    assert.are.equals(chips:getRating(cpu), 3)
  end)

  it("get the name", function()
    local cpu = chips:create("CPU", 1)
    assert.are.equals(chips:getName(cpu), "CPU")
  end)

  it("get the price L1", function()
    local cpu = chips:create("CPU", 1)
    assert.are.equals(chips:getPrice(cpu), 150)
  end)

  it("get the price L3", function()
    local cop = chips:create("Coprocessor", 3)
    assert.are.equals(chips:getPrice(cop), 1125)
  end)

  it("get the descriptive text", function()
    local cop = chips:create("Coprocessor", 3)
    assert.are.equals(chips:getText(cop), "Coprocessor L3")
  end)

  it("erros when creating an invalid chip", function()
    local func = function()
      chips:create("Unreal item", 3)
    end
    assert.has.errors(func)
  end)

end)
