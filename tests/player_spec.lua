describe("Player", function()

  local player = require("player")
  
  it("starts poor", function()
    local db = {}
    db.player = player:create(nil)
    assert.are.equal(player:getCredits(db), 0)
  end)

  it("gets paid", function()
    local db = {}
    db.player = player:create(nil)
    player:addCredits(db, 42)
    assert.are.equal(player:getCredits(db), 42)
  end)

  it("spends credits", function()
    local db = {}
    db.player = player:create(nil)
    player:addCredits(db, 42)
    local result = player:spendCredits(db, 22)
    assert.is_true(result)
    assert.are.equal(player:getCredits(db), 20)
  end)

  it("can't overspend credits", function()
    local db = {}
    db.player = player:create(nil)
    player:addCredits(db, 42)
    local result = player:spendCredits(db, 50)
    assert.is_false(result)
    assert.are.equal(player:getCredits(db), 42)
  end)

end)
