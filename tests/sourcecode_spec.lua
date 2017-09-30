describe("sourcecode", function()

  local Player = require("player")
  local Sourcecode = require("sourcecode")
  local playerdata = nil

  -- create a new player for each test
  before_each(function()
    playerdata = Player:create()
  end)

  it("create", function()

    -- the player chip design skill limits source rating
    local code = Sourcecode:create(playerdata, "Stealth Firmware", 1)
    assert.are.equals("Stealth Firmware", code.class)
    assert.are.equals(1, code.rating)
    assert.are.equals(4, code.complexity)
    assert.are.equals(1, code.maxBuildRating)
    assert.is_false(code.isSoftware)
    assert.is_true(code.isChip)

  end)

  it("can't have rating above player's skill", function()

    -- upgrade the player chip design to level 2
    Player:addSkillPoints(playerdata, 1)
    Player:spendSkillPoints(playerdata, "chip design")
    assert.are.equals(2, Player:getSkillLevel(playerdata, "chip design"))

    -- attempt to create a chip source level 3
    local code = Sourcecode:create(playerdata, "Stealth Firmware", 3)

    -- check the rating is limited to the player skill
    assert.are.equals(2, code.rating)

  end)

  it("development time for new code", function()

    -- upgrade the player chip design to level 2
    Player:addSkillPoints(playerdata, 1)
    Player:spendSkillPoints(playerdata, "chip design")

    local code = Sourcecode:create(playerdata, "CPU", 2)
    assert.are.equals(11, code.daysToComplete)

  end)

  it("development time reduced when updating code", function()

    -- upgrade the player chip design to level 2
    Player:addSkillPoints(playerdata, 1)
    Player:spendSkillPoints(playerdata, "chip design")

    -- add an lower rated source of the same class
    local oldversion = Sourcecode:create(playerdata, "CPU", 1)
    Player:addSourcecode(playerdata, oldversion)

    -- create a higher rated source
    local code = Sourcecode:create(playerdata, "CPU", 2)

    -- test the days are reduced because we own older source
    assert.are.equals(8, code.daysToComplete)

  end)

  it("cannot build undeveloped code", function()

    local code = Sourcecode:create(playerdata, "Medic", 1)
    Sourcecode:build(playerdata, code)
    local ware = Player:findSoftwareByClass(playerdata, "Medic")
    assert.is_nil(ware)

  end)

  it("build software", function()

    -- this adds new software to the player's software list.
    local code = Sourcecode:create(playerdata, "Medic", 1)

    -- complete the development
    while code.daysToComplete > 0 do
      Sourcecode:workOnCode(playerdata, code)
    end

    -- compile it
    local buildResult = Sourcecode:build(playerdata, code)
    assert.is_true(buildResult)

    -- test the player has it in the software list
    local ware = Player:findSoftwareByClass(playerdata, "Medic")
    assert.is.truthy(ware)

  end)

  it("cook it to a chip", function()

    -- give the player a chip burner
    local Hardware = require("hardware")
    local burner = Hardware:create("Chip Burner", 1)
    Player:addHardware(playerdata, burner)

    -- create the chip source
    local code = Sourcecode:create(playerdata, "CPU", 1)

    -- complete the development
    while code.daysToComplete > 0 do
      Sourcecode:workOnCode(playerdata, code)
    end

    -- compile it
    local buildResult = Sourcecode:build(playerdata, code)
    assert.is_true(buildResult)

    -- test the chip is cooking
    local project = Player:getCookingChip(playerdata)
    assert.are.equals(code, project)

    -- pass time so it cooks
    while code.cooktime > 0 do
      Sourcecode:cookChip(playerdata)
    end

    -- test the cooking project has been removed
    project = Player:getCookingChip(playerdata)
    assert.is_nil(project)

    -- test the player has this chip installed
    local ownedChip = Player:findChipByClass(playerdata, code.class)
    assert.is.truthy(ownedChip)
    assert.are.equals(code.class, ownedChip.class)

    -- and the class and rating match
    assert.are.equals(code.rating, ownedChip.rating)

  end)


  --it("example usage", function()

    --table.insert(playerdata.sourcecode, Sourcecode:create(playerdata, "Smoke", 5))
    --table.insert(playerdata.sourcecode, Sourcecode:create(playerdata, "CPU", 5))

    --local list = Sourcecode:getSourceList(playerdata)

    --for k,v in pairs(list) do
      --print(k, v.type, v.class, v.complexity, v["max build rating"], "*" .. v["owned rating"])
    --end

  --end)


end)
