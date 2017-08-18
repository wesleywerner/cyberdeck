describe("Intrusion Countermeasure Elements", function()

  local ice = require('ice')
  local db = nil

  it("get the type definition", function()
    local probe = ice:create(db, "Probe", 2)
    assert.are.equals(ice:getType(db, probe), ice.types["Probe"])
  end)

  it("get the rating", function()
    local probe = ice:create(db, "Probe", 3)
    assert.are.equals(ice:getRating(db, probe), 3)
  end)

  it("get the rating against hardware", function()
    local trace = ice:create(db, "Trace", 3)
    trace.analyzedLevel = 2
    assert.are.equals(ice:getRating(db, trace, true), 3)
  end)

  it("get the rating after being analyzed", function()
    local probe = ice:create(db, "Probe", 3)
    probe.analyzedLevel = 2
    assert.are.equals(ice:getRating(db, probe), 1)
  end)

  it("get the rating when weakened", function()
    local probe = ice:create(db, "Probe", 3)
    probe.weakened = true
    assert.are.equals(ice:getRating(db, probe), -1)
  end)

  it("get the attack rating", function()
    local black = ice:create(db, "Attack", 2)
    assert.are.equals(ice:getAttackRating(db, black), 2)
  end)

  it("get the sensor rating", function()
    local probe = ice:create(db, "Probe", 2)
    assert.are.equals(ice:getSensorRating(db, probe), 4)
  end)

  it("get the name with max clamp", function()
    local gate = ice:create(db, "Gateway", 100) -- a ridiculous rating
    assert.are.equals(ice:getName(db, gate), "Big Bouncer")
  end)

  it("get the name for L2", function()
    local gate = ice:create(db, "Gateway", 2)
    assert.are.equals(ice:getName(db, gate), "Fence")
  end)

  it("get the name for databomb ICE with max clamp", function()
    local worm = ice:create(db, "Tapeworm", 100, {"databomb"} )  -- a ridiculous rating
    assert.are.equals(ice:getName(db, worm), "Da Bomb")
  end)

  it("get the name for hardened ICE", function()
    local black = ice:create(db, "Attack", 2, {"hardened"} )
    assert.are.equals(ice:getName(db, black), "Knight")
  end)

  it("get the name for phasing ICE", function()
    local black = ice:create(db, "Attack", 2, {"phasing"} )
    assert.are.equals(ice:getName(db, black), "Bugs")
  end)

  it("get the name for crasher ICE", function()
    local black = ice:create(db, "Attack", 2, {"crasher"} )
    assert.are.equals(ice:getName(db, black), "Spider")
  end)

  it("get the name for lethal ICE", function()
    local black = ice:create(db, "Attack", 2, {"lethal"} )
    assert.are.equals(ice:getName(db, black), "Cowboy")
  end)

  it("get the descriptive text", function()
    local guard = ice:create(db, "Guardian", 3)
    assert.are.equals(ice:getName(db, guard), "Sentry")
  end)

  it("get the notes for non-analyzed ICE", function()
    local black = ice:create(db, "Attack", 2, {"dumper", "fryer"} )
    assert.are.equals(ice:getNotes(db, black), "Attacks intruders.")
  end)

  it("get the notes for analyzed ICE", function()
    local black = ice:create(db, "Attack", 2, {"dumper", "fryer"} )
    black.analyzedLevel = 2
    local exp = "Attacks intruders. Can dump your deck from the matrix. Can fry one of your hardware chips."
    assert.are.equals(ice:getNotes(db, black), exp)
  end)

  it("setting a valid state", function()
    local func = function()
      local gate = ice:create(db, "Gateway", 1)
      ice:setState(db, gate, "guarding")
    end
    assert.has_no.errors(func)
  end)

  it("setting an invalid state", function()
    local func = function()
      local gate = ice:create(db, "Gateway", 1)
      ice:setState(db, gate, "invalid selection")
    end
    assert.has.errors(func)
  end)

end)
