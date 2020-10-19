local tools = require('test_tools')
require('build/debug')
describe("system", function()

  local seed = 0
  local small_size = 1
  local large_size = 5
  
  describe("area map", function()
    generate_system(seed, small_size)
    local test_area = system.areas[1]
    it("has one area", function()
      assert.are.equal(1, #system.areas)
    end)
    it("has size", function()
      assert.is.equal(1, test_area.size)
    end)
    it("has map", function()
      assert.is.truthy(test_area.map)
    end)
  end)
  
  describe("nodes (small area)", function()
    generate_system(seed, small_size)
    local test_area = system.areas[1]
    it("has nodes", function()
      assert.is_true(#test_area.nodes > 1)
    end)
    it("has out_portal_node", function()
      assert.is.truthy(test_area.out_portal_node)
    end)
    it("has no in_portal_node", function()
      assert.is.falsy(test_area.in_portal_node)
    end)
    it("contains a CPU node", function()
      -- areas == 1 contain a CPU
      local test_node = tools.first(test_area.nodes,
        function(e)
          return e.NT == NT_CPU
        end)
      assert.is.truthy(test_node)
    end)
    it("should not contain a SPU node", function()
      -- areas == 1 dont contain a SPU
      local test_node = tools.first(test_area.nodes,
        function(e)
          return e.NT == NT_SPU
        end)
      assert.is.falsy(test_node)
    end)
    it("contains a security IO node", function()
      local test_node = tools.first(test_area.nodes,
        function(e)
          return e.NT == NT_COP and e.SUB == NST_COP_SECURITY
        end)
      assert.is.truthy(test_node)
    end)
    it("contains a datastore node", function()
      local test_node = tools.first(test_area.nodes,
        function(e)
          return e.NT == NT_DS
        end)
      assert.is.truthy(test_node)
    end)
    it("contains a IO node", function()
      local test_node = tools.first(test_area.nodes,
        function(e)
          return e.NT == NT_IO and not e.SUB
        end)
      assert.is.truthy(test_node)
    end)
    it("contains a ICE node", function()
      local test_node = tools.first(test_area.nodes,
        function(e)
          return e.NT == NT_IO and e.SUB == NST_IO_ICE_PORT
        end)
      assert.is.truthy(test_node)
    end)
  end)
  
  describe("nodes (large area)", function()
    generate_system(seed, large_size)
    local test_area = system.areas[2]
    it("has two areas", function()
      assert.are.equal(2, #system.areas)
    end)
    it("should not contain a CPU node", function()
      -- areas > 1 dont contain a CPU
      local test_node = tools.first(test_area.nodes,
        function(e)
          return e.NT == NT_CPU
        end)
      assert.is.falsy(test_node)
    end)
    it("contains a SPU node", function()
      -- areas > 1 contain a SPU
      local test_node = tools.first(test_area.nodes,
        function(e)
          return e.NT == NT_SPU
        end)
      assert.is.truthy(test_node)
    end)
    it("has out_portal_node", function()
      assert.is.truthy(test_area.out_portal_node)
    end)
    it("has in_portal_node", function()
      assert.is.truthy(test_area.in_portal_node)
    end)
  end)
  

end)
