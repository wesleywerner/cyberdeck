-- test framework
luaunit = require('luaunit')

-- logic to test
chips = require('chips')

-- isolate tests in a table
TestChips = {}

function TestChips:testType()
  local chip = chips("CPU", 1)
  luaunit.assertEquals(chip:getType(), chips.types['CPU'])
end

function TestChips:testRating()
  local chip = chips("CPU", 3)
  luaunit.assertEquals(chip:getRating(), 3)
end

function TestChips:testName()
  local chip = chips("CPU", 1)
  luaunit.assertEquals(chip:getName(), "CPU")
end

function TestChips:testPriceCPUL1()
  local chip = chips("CPU", 1)
  luaunit.assertEquals(chip:getPrice(), 150)
end

function TestChips:testPriceCoprocessorL3()
  local chip = chips("Coprocessor", 3)
  luaunit.assertEquals(chip:getPrice(), 1125)
end

function TestChips:testText()
  local chip = chips("Coprocessor", 3)
  luaunit.assertEquals(chip:getText(), "Coprocessor L3")
end

function TestChips:testConstructorValidation()
  local func = function()
    chips("Unreal item", 3)
  end
  luaunit.assertError(func)
end

-- allow stand-alone test
if not IS_TESTING_ALL then
  os.exit( luaunit.LuaUnit.run() )
end
