describe("Hardware", function()

  local hardware = require('hardware')
  local db = nil

  it("get the type definition", function()
    local hw = hardware:create(db, "Chip Burner", 1)
    assert.are.equals(hardware:getType(db, hw), hardware.types["Chip Burner"])
  end)

  it("get the rating", function()
    local hw = hardware:create(db, "Chip Burner", 2)
    assert.are.equals(hardware:getRating(db, hw), 2)
  end)

  it("get the hardware maximum rating", function()
    local hw = hardware:create(db, "Chip Burner", 1)
    assert.are.equals(hardware:getMaxRating(db, hw), 4)
  end)

  it("get the hardware name", function()
    local hw = hardware:create(db, "Chip Burner", 1)
    assert.are.equals(hardware:getName(db, hw), "Chip Burner")
  end)

  it("get the descriptive text", function()
    local hw = hardware:create(db, "Chip Burner", 1)
    assert.are.equals(hardware:getText(db, hw), "Chip Burner L1")
  end)

  it("get the descriptive text with suffix", function()
    local hw = hardware:create(db, "Bio Monitor", 2)
    assert.are.equals(hardware:getText(db, hw), "Bio Monitor (Auto Dump)")
  end)

  it("get the price L1 chip burner", function()
    local hw = hardware:create(db, "Chip Burner", 1)
    assert.are.equals(hardware:getPrice(db, hw), 1000)
  end)

  it("get the price L4 bio monitor", function()
    local hw = hardware:create(db, "Bio Monitor", 4)
    assert.are.equals(hardware:getPrice(db, hw), 4000)
  end)

  it("errors on creating invalid hardware", function()
    local func = function()
      hardware:create(db, "Unreal item", 1)
    end
    assert.has.errors(func)
  end)

end)
