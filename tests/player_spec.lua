describe("Player", function()

  local player = require("player")
  local playerdata = nil

  -- create a new player for each test
  before_each(function()
    playerdata = player:create()
  end)

  describe("credits", function()

    it("starts poor", function()

      -- verify starting credit amount
      assert.are.equals(player:getCredits(playerdata), 0)

    end)

    it("gets paid", function()

      -- add multiple credits
      player:addCredits(playerdata, 22)
      player:addCredits(playerdata, 20)

      -- verify the total
      assert.are.equals(player:getCredits(playerdata), 42)

    end)

    it("spends credits", function()

      -- start with some credits
      player:addCredits(playerdata, 42)

      -- spend some of it
      local didSpend = player:spendCredits(playerdata, 22)

      -- verify we spent it
      assert.is_true(didSpend)
      assert.are.equals(player:getCredits(playerdata), 20)

    end)

    it("can't overspend credits", function()

      -- start with some credits
      player:addCredits(playerdata, 42)

      -- spend more than we have
      local didSpend = player:spendCredits(playerdata, 50)

      -- verify result
      assert.is_false(didSpend)
      assert.are.equals(player:getCredits(playerdata), 42)

    end)

  end)

  describe("hardware", function()

    local hardware = require("hardware")

    it("add new", function()

      -- add new hardware to the player
      local burner = hardware:create("Chip Burner", 1)
      player:addHardware(playerdata, burner)

      -- verify the player owns it
      local owned = player:findHardwareByClass(playerdata, "Chip Burner")
      assert.are.equals(burner, owned)

    end)

    it("upgrade existing", function()

      -- player owns a low rated one
      local burnerL1 = hardware:create("Chip Burner", 1)
      local isburnerL1Added = player:addHardware(playerdata, burnerL1)
      assert.is_true(isburnerL1Added)

      -- add a higher rated one
      local burnerL2 = hardware:create("Chip Burner", 2)
      local isburnerL2Added = player:addHardware(playerdata, burnerL2)
      assert.is_true(isburnerL2Added)

      -- verify the new hardware is owned by the player
      local owned = player:findHardwareByClass(playerdata, "Chip Burner")
      assert.are.equals(burnerL2, owned)

      -- test the player received credits for selling the old hardware
      local resellValue = hardware:getResellPrice(burnerL1)
      assert.are.equals(player:getCredits(playerdata), resellValue)

    end)

    it("upgrade existing fails if owns better", function()

      -- already owns a high rated one
      local burnerL2 = hardware:create("Chip Burner", 2)
      local isburnerL2Added = player:addHardware(playerdata, burnerL2)
      assert.is_true(isburnerL2Added)

      -- try add a lower rated one
      local burnerL1 = hardware:create("Chip Burner", 1)
      local isburnerL1Added = player:addHardware(playerdata, burnerL1)
      assert.is_false(isburnerL1Added)

      -- verify results
      local owned = player:findHardwareByClass(playerdata, "Chip Burner")
      assert.are.equals(burnerL2, owned)

    end)

    it("remove existing", function()

      -- give the player a bio monitor
      local monitor = hardware:create("Bio Monitor", 2)
      player:addHardware(playerdata, monitor)

      -- no need to verify, the other test covers that for us

      -- remove it and verify
      player:removeHardware(playerdata, monitor)
      local owned = player:findHardwareByClass(playerdata, "Bio Monitor")
      assert.is_nil(owned)

    end)

  end)

  describe("software", function()

    local software = require("software")

    it("add new", function()

      -- add software to the player
      local prog = software:create("Attack", 1)
      local isAdded = player:addSoftware(playerdata, prog)

      -- verify it was added
      assert.is_true(isAdded)
      local owned = player:findSoftwareByClass(playerdata, "Attack")
      assert.are.equals(owned, prog)

    end)

    it("upgrade existing", function()

      -- add low rated software
      local prog1 = software:create("Attack", 1)
      local isProg1Added = player:addSoftware(playerdata, prog1)

      -- add a higher rated one
      local prog2 = software:create("Attack", 2)
      local isProg2Added = player:addSoftware(playerdata, prog2)

      -- verify the higher rated one was added
      assert.is_true(isProg1Added)
      assert.is_true(isProg2Added)
      local owned = player:findSoftwareByClass(playerdata, "Attack")
      assert.are.equals(owned, prog2)

    end)

    it("upgrade existing fails if owns better", function()

      -- already owns high rated
      local prog2 = software:create("Attack", 2)
      local isProg2Added = player:addSoftware(playerdata, prog2)

      -- try add lower rated of the same class
      local prog1 = software:create("Attack", 1)
      local isProg1Added = player:addSoftware(playerdata, prog1)

      -- verify the higher rated one was kept
      assert.is_false(isProg1Added)
      assert.is_true(isProg2Added)
      local owned = player:findSoftwareByClass(playerdata, "Attack")
      assert.are.equals(owned, prog2)

    end)

  end)

  describe("chips", function()

    local chips = require("chips")

    it("add new", function()

      -- add a cpu chip
      local cpu = chips:create("CPU", 1)
      local isAdded = player:addChip(playerdata, cpu)

      -- verify
      assert.is_true(isAdded)

      local owned = player:findChipByClass(playerdata, "CPU")
      assert.are.equals(cpu, owned)

    end)

    it("upgrade existing", function()

      -- add a lower chip
      local cpu1 = chips:create("CPU", 1)
      local cpu1added = player:addChip(playerdata, cpu1)

      -- add a higher chip
      local cpu2 = chips:create("CPU", 2)
      local cpu2added = player:addChip(playerdata, cpu2)

      -- verify
      assert.is_true(cpu1added)
      assert.is_true(cpu2added)

      local owned = player:findChipByClass(playerdata, "CPU")
      assert.are.equals(cpu2, owned)

    end)

    it("upgrade existing fails if owns better", function()

      -- add a higher chip
      local cpu2 = chips:create("CPU", 2)
      local cpu2added = player:addChip(playerdata, cpu2)

      -- try add a lower chip
      local cpu1 = chips:create("CPU", 1)
      local cpu1added = player:addChip(playerdata, cpu1)

      -- verify
      assert.is_false(cpu1added)
      assert.is_true(cpu2added)

      local owned = player:findChipByClass(playerdata, "CPU")
      assert.are.equals(cpu2, owned)

    end)

    it("remove existing", function()

      -- add a cpu chip
      local cpu = chips:create("CPU", 1)
      local isAdded = player:addChip(playerdata, cpu)
      local isRemoved = player:removeChip(playerdata, cpu)

      -- verify
      assert.is_true(isAdded)
      assert.is_true(isRemoved)

      local owned = player:findChipByClass(playerdata, "CPU")
      assert.is_nil(owned)

    end)

  end)

  describe("skills", function()

    it("errors getting invalid skill level", function()
      local func = function()
        player:getSkillLevel(playerdata, "invalid selection")
      end
      assert.has.errors(func, "\"invalid selection\" is not a valid skill class")
    end)

    it("starts unskilled", function()
      assert.are.equals(1, player:getSkillLevel(playerdata, "attack"))
    end)

    it("add points", function()

      -- earn some points
      player:addSkillPoints(playerdata, 2)

      -- verify
      assert.are.equals(2, player:getSkillPoints(playerdata))

    end)

    it("spend points", function()

      -- earn some points
      player:addSkillPoints(playerdata, 2)

      -- spend them
      local didSpend = player:spendSkillPoints(playerdata, "attack")

      -- verify
      assert.is_true(didSpend)
      assert.are.equals(2, player:getSkillLevel(playerdata, "attack"))

    end)

    it("cannot spend more points than cost", function()

      -- spend them
      local didSpend = player:spendSkillPoints(playerdata, "attack")

      -- verify the skill is still on level 1
      assert.is_false(didSpend)
      assert.are.equals(1, player:getSkillLevel(playerdata, "attack"))

    end)

  end)

  describe("reputation", function()

    it("starts unknown", function()

      assert.are.equals(1, playerdata.reputation.level)
      assert.are.equals(0, playerdata.reputation.points)
      assert.are.equals("Nobody", playerdata.reputation.text)

    end)

    it("add points", function()

      player:alterReputation(playerdata, 1)
      assert.are.equals(1, playerdata.reputation.level)
      assert.are.equals(1, playerdata.reputation.points)

    end)

    it("upgrade lifestyle with enough points", function()

      -- need 15 points to level up to reputation2
      player:alterReputation(playerdata, 7)
      player:alterReputation(playerdata, 7)
      player:alterReputation(playerdata, 1)
      assert.are.equals(2, playerdata.reputation.level)
      assert.are.equals("Wannabe", playerdata.reputation.text)

    end)

    it("limit reputation by lifestyle", function()

      -- max reputation for lifestyle 1 is 4
      playerdata.reputation.level = 4
      player:alterReputation(playerdata, 100) -- absurd increase, where 50 would be enough
      assert.are.equals(4, playerdata.reputation.level)

    end)

    it("reduce level with enough points lost", function()

      -- jump to level 2
      player:alterReputation(playerdata, 15)
      -- reduce points
      player:alterReputation(playerdata, -1)
      -- test if the level has dropped
      assert.are.equals(1, playerdata.reputation.level)

    end)

    it("reduce level when at max for lifestyle", function()

      -- jump to max level for lifstyle

      -- level 2
      player:alterReputation(playerdata, 15)
      -- level 3
      player:alterReputation(playerdata, 15)
      -- level 4
      player:alterReputation(playerdata, 20)

      assert.are.equals(4, playerdata.reputation.level)

      -- reduce points
      player:alterReputation(playerdata, -1)

      -- test if the level has dropped
      assert.are.equals(3, playerdata.reputation.level)
      assert.are.equals("Cyber Surfer", playerdata.reputation.text)


    end)

  end)

end)
