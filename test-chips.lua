-- test framework
luaunit = require('luaunit')

-- logic to test
chips = require('chips')

-- isolate tests in a table
TestChips = {}

function TestChips:testType()
  local chip = chips:create("CPU", 1)
  luaunit.assertEquals(chips:getType(chip), chips.types['CPU'])
end

function TestChips:testRating()
  local chip = chips:create("CPU", 3)
  luaunit.assertEquals(chips:getRating(chip), 3)
end

function TestChips:testName()
  local chip = chips:create("CPU", 1)
  luaunit.assertEquals(chips:getName(chip), "CPU")
end

function TestChips:testPriceCPUL1()
  local chip = chips:create("CPU", 1)
  luaunit.assertEquals(chips:getPrice(chip), 150)
end

function TestChips:testPriceCoprocessorL3()
  local chip = chips:create("Coprocessor", 3)
  luaunit.assertEquals(chips:getPrice(chip), 1125)
end

function TestChips:testText()
  local chip = chips:create("Coprocessor", 3)
  luaunit.assertEquals(chips:getText(chip), "Coprocessor L3")
end

function TestChips:testConstructorValidation()
  local func = function()
    chips:create("Unreal item", 3)
  end
  luaunit.assertError(func)
end

-- allow stand-alone test
if not IS_TESTING_ALL then
  os.exit( luaunit.LuaUnit.run() )
end
