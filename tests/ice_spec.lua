describe("Intrusion Countermeasure Elements", function()

  local ice = require('ice')

  it("get the type definition", function()
    local probe = ice:create("Probe", 2)
    assert.are.equals(ice:getType(probe), ice.types["Probe"])
  end)

  it("get the rating", function()
    local probe = ice:create("Probe", 3)
    assert.are.equals(ice:getRating(probe), 3)
  end)

  it("get the rating against hardware", function()
    local trace = ice:create("Trace", 3)
    trace.analyzedLevel = 2
    assert.are.equals(ice:getRating(trace, true), 3)
  end)

  it("get the rating after being analyzed", function()
    local probe = ice:create("Probe", 3)
    probe.analyzedLevel = 2
    assert.are.equals(ice:getRating(probe), 1)
  end)

  it("get the rating when weakened", function()
    local probe = ice:create("Probe", 3)
    probe.weakened = true
    assert.are.equals(ice:getRating(probe), -1)
  end)

  it("get the attack rating", function()
    local black = ice:create("Attack", 2)
    assert.are.equals(ice:getAttackRating(black), 2)
  end)

  it("get the sensor rating", function()
    local probe = ice:create("Probe", 2)
    assert.are.equals(ice:getSensorRating(probe), 4)
  end)

  it("get the name with max clamp", function()
    local gate = ice:create("Gateway", 100) -- a ridiculous rating
    assert.are.equals(ice:getName(gate), "Big Bouncer")
  end)

  it("get the name for L2", function()
    local gate = ice:create("Gateway", 2)
    assert.are.equals(ice:getName(gate), "Fence")
  end)

  it("get the name for databomb ICE with max clamp", function()
    local worm = ice:create("Tapeworm", 100, {"databomb"} )  -- a ridiculous rating
    assert.are.equals(ice:getName(worm), "Da Bomb")
  end)

  it("get the name for hardened ICE", function()
    local black = ice:create("Attack", 2, {"hardened"} )
    assert.are.equals(ice:getName(black), "Knight")
  end)

  it("get the name for phasing ICE", function()
    local black = ice:create("Attack", 2, {"phasing"} )
    assert.are.equals(ice:getName(black), "Bugs")
  end)

  it("get the name for crasher ICE", function()
    local black = ice:create("Attack", 2, {"crasher"} )
    assert.are.equals(ice:getName(black), "Spider")
  end)

  it("get the name for lethal ICE", function()
    local black = ice:create("Attack", 2, {"lethal"} )
    assert.are.equals(ice:getName(black), "Cowboy")
  end)

  it("get the descriptive text", function()
    local guard = ice:create("Guardian", 3)
    assert.are.equals(ice:getName(guard), "Sentry")
  end)

  it("get the notes for non-analyzed ICE", function()
    local black = ice:create("Attack", 2, {"dumper", "fryer"} )
    assert.are.equals(ice:getNotes(black), "Attacks intruders.")
  end)

  it("get the notes for analyzed ICE", function()
    local black = ice:create("Attack", 2, {"dumper", "fryer"} )
    black.analyzedLevel = 2
    local exp = "Attacks intruders. Can dump your deck from the matrix. Can fry one of your hardware chips."
    assert.are.equals(ice:getNotes(black), exp)
  end)

  it("setting a valid state", function()
    local func = function()
      local gate = ice:create("Gateway", 1)
      ice:setState(gate, "guarding")
    end
    assert.has_no.errors(func)
  end)

  it("setting an invalid state", function()
    local func = function()
      local gate = ice:create("Gateway", 1)
      ice:setState(gate, "invalid selection")
    end
    assert.has.errors(func)
  end)

end)
