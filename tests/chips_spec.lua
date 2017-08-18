describe("Chips", function()

  local chips = require('chips')
  local db = nil

  it("get the type definition", function()
    local cpu = chips:create(db, "CPU", 1)
    assert.are.equals(chips:getType(db, cpu), chips.types['CPU'])
  end)

  it("get the rating", function()
    local cpu = chips:create(db, "CPU", 3)
    assert.are.equals(chips:getRating(db, cpu), 3)
  end)

  it("get the name", function()
    local cpu = chips:create(db, "CPU", 1)
    assert.are.equals(chips:getName(db, cpu), "CPU")
  end)

  it("get the price L1", function()
    local cpu = chips:create(db, "CPU", 1)
    assert.are.equals(chips:getPrice(db, cpu), 150)
  end)

  it("get the price L3", function()
    local cop = chips:create(db, "Coprocessor", 3)
    assert.are.equals(chips:getPrice(db, cop), 1125)
  end)

  it("get the descriptive text", function()
    local cop = chips:create(db, "Coprocessor", 3)
    assert.are.equals(chips:getText(db, cop), "Coprocessor L3")
  end)

  it("erros when creating an invalid chip", function()
    local func = function()
      chips:create(db, "Unreal item", 3)
    end
    assert.has.errors(func)
  end)

end)
