-- test framework
luaunit = require('luaunit')

-- logic to test
ICE = require('ice')

-- isolate tests in a table
TestICE = {}

function TestICE:testType()
  local ice = ICE("Probe", 2)
  luaunit.assertEquals(ice:getType(), ICE.types["Probe"])
end

function TestICE:testRating()
  local ice = ICE("Probe", 3)
  luaunit.assertEquals(ice:getRating(), 3)
end

function TestICE:testNameMax()
  local ice = ICE("Gateway", 100) -- a ridiculous rating
  luaunit.assertEquals(ice:getName(), "Big Bouncer")
end

function TestICE:testNameGateway()
  local ice = ICE("Gateway", 2)
  luaunit.assertEquals(ice:getName(), "Fence")
end

function TestICE:testNameProbe()
  local ice = ICE("Probe", 2)
  luaunit.assertEquals(ice:getName(), "Gazer")
end

function TestICE:testNameGuardian()
  local ice = ICE("Guardian", 2)
  luaunit.assertEquals(ice:getName(), "Protector")
end

function TestICE:testNameTapeworm()
  local ice = ICE("Tapeworm", 2)
  luaunit.assertEquals(ice:getName(), "Boa")
end

function TestICE:testNameAttack()
  local ice = ICE("Attack", 2)
  luaunit.assertEquals(ice:getName(), "Brute")
end

function TestICE:testNameForDataBomb()
  local ice = ICE("Tapeworm", 100, {"databomb"} )  -- a ridiculous rating
  luaunit.assertEquals(ice:getName(), "Da Bomb")
end

function TestICE:testNameForHardened()
  local ice = ICE("Attack", 2, {"hardened"} )
  luaunit.assertEquals(ice:getName(), "Knight")
end

function TestICE:testNameForPhasing()
  local ice = ICE("Attack", 2, {"phasing"} )
  luaunit.assertEquals(ice:getName(), "Bugs")
end

function TestICE:testNameForCrasher()
  local ice = ICE("Attack", 2, {"crasher"} )
  luaunit.assertEquals(ice:getName(), "Spider")
end

function TestICE:testNameForLethal()
  local ice = ICE("Attack", 2, {"lethal"} )
  luaunit.assertEquals(ice:getName(), "Cowboy")
end

function TestICE:testNameTrace()
  local ice = ICE("Trace", 2)
  luaunit.assertEquals(ice:getName(), "Hound")
end

function TestICE:testText()
  local ice = ICE("Guardian", 3)
  luaunit.assertEquals(ice:getName(), "Sentry")
end

function TestICE:testNotesNotAnalyzed()
  local ice = ICE("Attack", 2, {"dumper", "fryer"} )
  ice.analyzed = 2
  luaunit.assertEquals(ice:getNotes(), "Attacks intruders.")
end

function TestICE:testNotesAnalyzed()
  local ice = ICE("Attack", 2, {"dumper", "fryer"} )
  ice.analyzedLevel = 2
  luaunit.assertEquals(ice:getNotes(), "Attacks intruders. Can dump your deck from the matrix. Can fry one of your hardware chips.")
end

-- allow stand-alone test
if not IS_TESTING_ALL then
  os.exit( luaunit.LuaUnit.run() )
end
