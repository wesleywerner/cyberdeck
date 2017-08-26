describe("Hardware", function()

  local hardware = require('hardware')

  it("get the type definition", function()
    local hw = hardware:create("Chip Burner", 1)
    assert.are.equals(hardware:getType(hw), hardware.types["Chip Burner"])
  end)

  it("get the rating", function()
    local hw = hardware:create("Chip Burner", 2)
    assert.are.equals(hardware:getRating(hw), 2)
  end)

  it("get the hardware maximum rating", function()
    local hw = hardware:create("Chip Burner", 1)
    assert.are.equals(hardware:getMaxRating(hw), 4)
  end)

  it("get the hardware class", function()
    local hw = hardware:create("Chip Burner", 1)
    assert.are.equals(hw.class, "Chip Burner")
  end)

  it("get the descriptive text", function()
    local hw = hardware:create("Chip Burner", 1)
    assert.are.equals(hardware:getText(hw), "Chip Burner L1")
  end)

  it("get the descriptive text with suffix", function()
    local hw = hardware:create("Bio Monitor", 2)
    assert.are.equals(hardware:getText(hw), "Bio Monitor (Auto Dump)")
  end)

  it("get the price L1 chip burner", function()
    local hw = hardware:create("Chip Burner", 1)
    assert.are.equals(hardware:getPrice(hw), 1000)
  end)

  it("get the price L4 bio monitor", function()
    local hw = hardware:create("Bio Monitor", 4)
    assert.are.equals(hardware:getPrice(hw), 4000)
  end)

  it("errors on creating invalid hardware", function()
    local func = function()
      hardware:create("Unreal item", 1)
    end
    assert.has.errors(func)
  end)

end)
