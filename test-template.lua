-- test framework
luaunit = require('luaunit')

-- logic to test
-- require('program')

-- isolate tests in a table
TestContainer = {}

function TestContainer:testType()
  luaunit.assertEquals("the meaning of the universe", 42)
end

function TestContainer:testRating()
  luaunit.assertEquals("the meaning of the universe", 42)
end

function TestContainer:testName()
  luaunit.assertEquals("the meaning of the universe", 42)
end

function TestContainer:testText()
  luaunit.assertEquals("the meaning of the universe", 42)
end

-- allow stand-alone test
if not IS_TESTING_ALL then
  os.exit( luaunit.LuaUnit.run() )
end
