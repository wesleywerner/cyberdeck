describe("Player", function()

  local player = require("player")
  local hardware = require("hardware")
  local db = nil
  
  -- create a new player for each test
  before_each(function()
    db = {}
    db.player = player:create(nil)
  end)

  it("starts poor", function()
    assert.are.equal(player:getCredits(db), 0)
  end)

  it("gets paid", function()
    player:addCredits(db, 42)
    assert.are.equal(player:getCredits(db), 42)
  end)

  it("spends credits", function()
    player:addCredits(db, 42)
    local result = player:spendCredits(db, 22)
    assert.is_true(result)
    assert.are.equal(player:getCredits(db), 20)
  end)

  it("can't overspend credits", function()
    player:addCredits(db, 42)
    local result = player:spendCredits(db, 50)
    assert.is_false(result)
    assert.are.equal(player:getCredits(db), 42)
  end)
  
  it("adds new hardware", function()
    local burner = hardware:create(db, "Chip Burner", 1)
    player:addHardware(db, burner)
    local verified = player:findHardwareByName(db, "Chip Burner")
    assert.are.equal(burner, verified)
  end)
  
  it("fails adding existing hardware", function()
    local burnerL1 = hardware:create(db, "Chip Burner", 1)
    local burnerL2 = hardware:create(db, "Chip Burner", 2)
    local func = function()
      player:addHardware(db, burnerL1)
      player:addHardware(db, burnerL2)
    end
    assert.has.errors(func, "cannot add hardware the player already owns")
  end)
  
  it("removes existing hardware", function()
    local monitor = hardware:create(db, "Bio Monitor", 2)
    player:addHardware(db, monitor)
    player:removeHardware(db, monitor)
    local verified = player:findHardwareByName(db, "Bio Monitor")
    assert.is_nil(verified)
  end)
  
  

end)
