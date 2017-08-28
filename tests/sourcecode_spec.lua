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

  it("estimated time to completion for new source", function()

    -- upgrade the player chip design to level 2
    Player:addSkillPoints(playerdata, 1)
    Player:spendSkillPoints(playerdata, "chip design")

    local code = Sourcecode:create(playerdata, "CPU", 2)
    assert.are.equals(11, code.daysToComplete)

  end)

  it("estimated time to completion for existing source", function()

    -- upgrade the player chip design to level 2
    Player:addSkillPoints(playerdata, 1)
    Player:spendSkillPoints(playerdata, "chip design")

    -- add an lower rated source of the same class
    local oldversion = Sourcecode:create(playerdata, "CPU", 1)
    table.insert(playerdata.sourcecode, oldversion)

    -- create a higher rated source
    local code = Sourcecode:create(playerdata, "CPU", 2)

    -- test the days are reduced because we own older source
    assert.are.equals(8, code.daysToComplete)

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
