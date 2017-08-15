-- test framework
luaunit = require('luaunit')

-- logic to test
ICE = require('ice')

-- isolate tests in a table
TestICE = {}

function TestICE:testType()
  local ice = ICE:create("Probe", 2)
  luaunit.assertEquals(ICE:getType(ice), ICE.types["Probe"])
end

function TestICE:testRating()
  local ice = ICE:create("Probe", 3)
  luaunit.assertEquals(ICE:getRating(ice), 3)
end

function TestICE:testRatingVersusHardware()
  local ice = ICE:create("Trace", 3)
  ice.analyzedLevel = 2
  luaunit.assertEquals(ICE:getRating(ice, true), 3)
end

function TestICE:testRatingAnalyzed()
  local ice = ICE:create("Probe", 3)
  ice.analyzedLevel = 2
  luaunit.assertEquals(ICE:getRating(ice), 1)
end

function TestICE:testRatingWeakend()
  local ice = ICE:create("Probe", 3)
  ice.weakened = true
  luaunit.assertEquals(ICE:getRating(ice), -1)
end

function TestICE:testRatingAttack()
  local ice = ICE:create("Attack", 2)
  luaunit.assertEquals(ICE:getAttackRating(ice), 2)
end

function TestICE:testRatingSensor()
  local ice = ICE:create("Probe", 2)
  luaunit.assertEquals(ICE:getSensorRating(ice), 4)
end

function TestICE:testNameMax()
  local ice = ICE:create("Gateway", 100) -- a ridiculous rating
  luaunit.assertEquals(ICE:getName(ice), "Big Bouncer")
end

function TestICE:testNameGateway()
  local ice = ICE:create("Gateway", 2)
  luaunit.assertEquals(ICE:getName(ice), "Fence")
end

function TestICE:testNameProbe()
  local ice = ICE:create("Probe", 2)
  luaunit.assertEquals(ICE:getName(ice), "Gazer")
end

function TestICE:testNameGuardian()
  local ice = ICE:create("Guardian", 2)
  luaunit.assertEquals(ICE:getName(ice), "Protector")
end

function TestICE:testNameTapeworm()
  local ice = ICE:create("Tapeworm", 2)
  luaunit.assertEquals(ICE:getName(ice), "Boa")
end

function TestICE:testNameAttack()
  local ice = ICE:create("Attack", 2)
  luaunit.assertEquals(ICE:getName(ice), "Brute")
end

function TestICE:testNameForDataBomb()
  local ice = ICE:create("Tapeworm", 100, {"databomb"} )  -- a ridiculous rating
  luaunit.assertEquals(ICE:getName(ice), "Da Bomb")
end

function TestICE:testNameForHardened()
  local ice = ICE:create("Attack", 2, {"hardened"} )
  luaunit.assertEquals(ICE:getName(ice), "Knight")
end

function TestICE:testNameForPhasing()
  local ice = ICE:create("Attack", 2, {"phasing"} )
  luaunit.assertEquals(ICE:getName(ice), "Bugs")
end

function TestICE:testNameForCrasher()
  local ice = ICE:create("Attack", 2, {"crasher"} )
  luaunit.assertEquals(ICE:getName(ice), "Spider")
end

function TestICE:testNameForLethal()
  local ice = ICE:create("Attack", 2, {"lethal"} )
  luaunit.assertEquals(ICE:getName(ice), "Cowboy")
end

function TestICE:testNameTrace()
  local ice = ICE:create("Trace", 2)
  luaunit.assertEquals(ICE:getName(ice), "Hound")
end

function TestICE:testText()
  local ice = ICE:create("Guardian", 3)
  luaunit.assertEquals(ICE:getName(ice), "Sentry")
end

function TestICE:testNotesNotAnalyzed()
  local ice = ICE:create("Attack", 2, {"dumper", "fryer"} )
  ice.analyzed = 2
  luaunit.assertEquals(ICE:getNotes(ice), "Attacks intruders.")
end

function TestICE:testNotesAnalyzed()
  local ice = ICE:create("Attack", 2, {"dumper", "fryer"} )
  ice.analyzedLevel = 2
  luaunit.assertEquals(ICE:getNotes(ice), "Attacks intruders. Can dump your deck from the matrix. Can fry one of your hardware chips.")
end

function TestICE:testStateValid()
  local ice = ICE:create("Gateway", 1)
  ICE:setState(ice, "guarding")
end

function TestICE:testStateInValid()
  local func = function()
    local ice = ICE:create("Gateway", 1)
    ICE:setState(ice, "invalid selection")
  end
  luaunit.assertError(func)
end

-- allow stand-alone test
if not IS_TESTING_ALL then
  os.exit( luaunit.LuaUnit.run() )
end
