describe("Player", function()

  local player = require("player")
  local db = nil

  -- create a new player for each test
  before_each(function()
    db = {}
    db.player = player:create(nil)
  end)
  
  describe("Player credits", function()

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

  end)

  describe("Player hardware", function()

    local hardware = require("hardware")

    it("adds new to collection", function()
      local burner = hardware:create(db, "Chip Burner", 1)
      player:addHardware(db, burner)
      local verified = player:findHardwareByName(db, "Chip Burner")
      assert.are.equal(burner, verified)
    end)

    it("upgrades existing to higher rated", function()
      local burnerL1 = hardware:create(db, "Chip Burner", 1)
      local burnerL2 = hardware:create(db, "Chip Burner", 2)
      local lowerResult = player:addHardware(db, burnerL1)
      local higherResult = player:addHardware(db, burnerL2)
      assert.is_true(lowerResult)
      assert.is_true(higherResult)
      -- verify the new hardware is owned by the player
      local verified = player:findHardwareByName(db, "Chip Burner")
      assert.are.equal(burnerL2, verified)
      -- test the player received credits for selling the old hardware
      local resellValue = hardware:getResellPrice(db, burnerL1)
      assert.are.equal(player:getCredits(db), resellValue)
    end)

    it("fails upgrading to lower rated", function()
      local burnerL1 = hardware:create(db, "Chip Burner", 1)
      local burnerL2 = hardware:create(db, "Chip Burner", 2)
      local higherResult = player:addHardware(db, burnerL2)
      local lowerResult = player:addHardware(db, burnerL1)
      assert.is_true(higherResult)
      assert.is_false(lowerResult)
      local verified = player:findHardwareByName(db, "Chip Burner")
      assert.are.equal(burnerL2, verified)
    end)

    it("removes existing", function()
      local monitor = hardware:create(db, "Bio Monitor", 2)
      player:addHardware(db, monitor)
      player:removeHardware(db, monitor)
      local verified = player:findHardwareByName(db, "Bio Monitor")
      assert.is_nil(verified)
    end)

  end)

  describe("Player software", function()

    local software = require("software")

    it("adds new to collection", function()
      local prog = software:create(db, "Attack", 1)
      local result = player:addSoftware(db, prog)
      assert.is_true(result)
      -- verify
      local verified = player:findSoftwareByClass(db, "Attack")
      assert.are.equal(verified, prog)
    end)

    it("upgrades existing", function()
      local prog1 = software:create(db, "Attack", 1)
      local prog2 = software:create(db, "Attack", 2)
      local result1 = player:addSoftware(db, prog1)
      local result2 = player:addSoftware(db, prog2)
      assert.is_true(result1)
      assert.is_true(result2)
      -- verify
      local verified = player:findSoftwareByClass(db, "Attack")
      assert.are.equal(verified, prog2)
    end)

    it("fails upgrading to a lower rated", function()
      local prog1 = software:create(db, "Attack", 1)
      local prog2 = software:create(db, "Attack", 2)
      local result2 = player:addSoftware(db, prog2)
      local result1 = player:addSoftware(db, prog1)
      assert.is_false(result1)
      assert.is_true(result2)
      -- verify
      local verified = player:findSoftwareByClass(db, "Attack")
      assert.are.equal(verified, prog2)
    end)

  end)

end)
