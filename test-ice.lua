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

function TestICE:testNameWithOptionMax()
  local ice = ICE("Tapeworm", 100)  -- a ridiculous rating
  ice:setFlag("data bomb")
  luaunit.assertEquals(ice:getName(), "Da Bomb")
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

function TestICE:testNameAttackHardened()
  local ice = ICE("Attack", 2)
  ice:setFlag("hardened")
  luaunit.assertEquals(ice:getName(), "Knight")
end

function TestICE:testNameAttackPhasing()
  local ice = ICE("Attack", 2)
  ice:setFlag("phasing")
  luaunit.assertEquals(ice:getName(), "Bugs")
end

function TestICE:testNameAttackCrash()
  local ice = ICE("Attack", 2)
  ice:setFlag("crash")
  luaunit.assertEquals(ice:getName(), "Spider")
end

function TestICE:testNameAttackLethal()
  local ice = ICE("Attack", 2)
  ice:setFlag("lethal")
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

-- allow stand-alone test
if not IS_TESTING_ALL then
  os.exit( luaunit.LuaUnit.run() )
end