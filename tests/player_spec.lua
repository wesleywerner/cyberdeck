describe("Player", function()

  local player = require("player")
  local db = nil

  -- create a new player for each test
  before_each(function()
    db = {}
    db.player = player:create(db)
  end)

  describe("credits", function()

    it("starts poor", function()

      -- verify starting credit amount
      assert.are.equal(player:getCredits(db), 0)

    end)

    it("gets paid", function()

      -- add multiple credits
      player:addCredits(db, 22)
      player:addCredits(db, 20)

      -- verify the total
      assert.are.equal(player:getCredits(db), 42)

    end)

    it("spends credits", function()

      -- start with some credits
      player:addCredits(db, 42)

      -- spend some of it
      local didSpend = player:spendCredits(db, 22)

      -- verify we spent it
      assert.is_true(didSpend)
      assert.are.equal(player:getCredits(db), 20)

    end)

    it("can't overspend credits", function()

      -- start with some credits
      player:addCredits(db, 42)

      -- spend more than we have
      local didSpend = player:spendCredits(db, 50)

      -- verify result
      assert.is_false(didSpend)
      assert.are.equal(player:getCredits(db), 42)

    end)

  end)

  describe("hardware", function()

    local hardware = require("hardware")

    it("add new", function()

      -- add new hardware to the player
      local burner = hardware:create(db, "Chip Burner", 1)
      player:addHardware(db, burner)

      -- verify the player owns it
      local owned = player:findHardwareByClass(db, "Chip Burner")
      assert.are.equal(burner, owned)

    end)

    it("upgrade existing", function()

      -- player owns a low rated one
      local burnerL1 = hardware:create(db, "Chip Burner", 1)
      local isburnerL1Added = player:addHardware(db, burnerL1)
      assert.is_true(isburnerL1Added)

      -- add a higher rated one
      local burnerL2 = hardware:create(db, "Chip Burner", 2)
      local isburnerL2Added = player:addHardware(db, burnerL2)
      assert.is_true(isburnerL2Added)

      -- verify the new hardware is owned by the player
      local owned = player:findHardwareByClass(db, "Chip Burner")
      assert.are.equal(burnerL2, owned)

      -- test the player received credits for selling the old hardware
      local resellValue = hardware:getResellPrice(db, burnerL1)
      assert.are.equal(player:getCredits(db), resellValue)

    end)

    it("upgrade existing fails if owns better", function()

      -- already owns a high rated one
      local burnerL2 = hardware:create(db, "Chip Burner", 2)
      local isburnerL2Added = player:addHardware(db, burnerL2)
      assert.is_true(isburnerL2Added)

      -- try add a lower rated one
      local burnerL1 = hardware:create(db, "Chip Burner", 1)
      local isburnerL1Added = player:addHardware(db, burnerL1)
      assert.is_false(isburnerL1Added)

      -- verify results
      local owned = player:findHardwareByClass(db, "Chip Burner")
      assert.are.equal(burnerL2, owned)

    end)

    it("remove existing", function()

      -- give the player a bio monitor
      local monitor = hardware:create(db, "Bio Monitor", 2)
      player:addHardware(db, monitor)

      -- no need to verify, the other test covers that for us

      -- remove it and verify
      player:removeHardware(db, monitor)
      local owned = player:findHardwareByClass(db, "Bio Monitor")
      assert.is_nil(owned)

    end)

  end)

  describe("software", function()

    local software = require("software")

    it("add new", function()

      -- add software to the player
      local prog = software:create(db, "Attack", 1)
      local isAdded = player:addSoftware(db, prog)

      -- verify it was added
      assert.is_true(isAdded)
      local owned = player:findSoftwareByClass(db, "Attack")
      assert.are.equal(owned, prog)

    end)

    it("upgrade existing", function()

      -- add low rated software
      local prog1 = software:create(db, "Attack", 1)
      local isProg1Added = player:addSoftware(db, prog1)

      -- add a higher rated one
      local prog2 = software:create(db, "Attack", 2)
      local isProg2Added = player:addSoftware(db, prog2)

      -- verify the higher rated one was added
      assert.is_true(isProg1Added)
      assert.is_true(isProg2Added)
      local owned = player:findSoftwareByClass(db, "Attack")
      assert.are.equal(owned, prog2)

    end)

    it("upgrade existing fails if owns better", function()

      -- already owns high rated
      local prog2 = software:create(db, "Attack", 2)
      local isProg2Added = player:addSoftware(db, prog2)

      -- try add lower rated of the same class
      local prog1 = software:create(db, "Attack", 1)
      local isProg1Added = player:addSoftware(db, prog1)

      -- verify the higher rated one was kept
      assert.is_false(isProg1Added)
      assert.is_true(isProg2Added)
      local owned = player:findSoftwareByClass(db, "Attack")
      assert.are.equal(owned, prog2)

    end)

  end)

  describe("chips", function()

    local chips = require("chips")

    it("add new", function()

      -- add a cpu chip
      local cpu = chips:create(db, "CPU", 1)
      local isAdded = player:addChip(db, cpu)

      -- verify
      assert.is_true(isAdded)

      local owned = player:findChipByClass(db, "CPU")
      assert.are.equal(cpu, owned)

    end)

    it("upgrade existing", function()

      -- add a lower chip
      local cpu1 = chips:create(db, "CPU", 1)
      local cpu1added = player:addChip(db, cpu1)

      -- add a higher chip
      local cpu2 = chips:create(db, "CPU", 2)
      local cpu2added = player:addChip(db, cpu2)

      -- verify
      assert.is_true(cpu1added)
      assert.is_true(cpu2added)

      local owned = player:findChipByClass(db, "CPU")
      assert.are.equal(cpu2, owned)

    end)

    it("upgrade existing fails if owns better", function()

      -- add a higher chip
      local cpu2 = chips:create(db, "CPU", 2)
      local cpu2added = player:addChip(db, cpu2)

      -- try add a lower chip
      local cpu1 = chips:create(db, "CPU", 1)
      local cpu1added = player:addChip(db, cpu1)

      -- verify
      assert.is_false(cpu1added)
      assert.is_true(cpu2added)

      local owned = player:findChipByClass(db, "CPU")
      assert.are.equal(cpu2, owned)

    end)

    it("remove existing", function()

      -- add a cpu chip
      local cpu = chips:create(db, "CPU", 1)
      local isAdded = player:addChip(db, cpu)
      local isRemoved = player:removeChip(db, cpu)

      -- verify
      assert.is_true(isAdded)
      assert.is_true(isRemoved)

      local owned = player:findChipByClass(db, "CPU")
      assert.is_nil(owned)

    end)

  end)

  describe("skills", function()

    it("errors getting invalid skill level", function()
      local func = function()
        player:getSkillLevel(db, "invalid selection")
      end
      assert.has.errors(func, "\"invalid selection\" is not a valid skill class")
    end)

    it("starts unskilled", function()
      assert.are.equal(1, player:getSkillLevel(db, "attack"))
    end)

    it("add points", function()

      -- earn some points
      player:addSkillPoints(db, 2)

      -- verify
      assert.are.equal(2, player:getSkillPoints(db))

    end)

    it("spend points", function()

      -- earn some points
      player:addSkillPoints(db, 2)

      -- spend them
      local didSpend = player:spendSkillPoints(db, "attack")

      -- verify
      assert.is_true(didSpend)
      assert.are.equal(2, player:getSkillLevel(db, "attack"))

    end)

    it("cannot spend more points than cost", function()

      -- spend them
      local didSpend = player:spendSkillPoints(db, "attack")

      -- verify the skill is still on level 1
      assert.is_false(didSpend)
      assert.are.equal(1, player:getSkillLevel(db, "attack"))

    end)

  end)

end)
