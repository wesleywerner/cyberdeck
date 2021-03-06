describe("system", function()

  local seed = 0

  -- our test node specification
  local function nodeDefinition()
    return {
      {
        ["type"] = "central processing node",
        ["minimum"] = 1,
        ["spare"] = 0
      },
      {
        ["type"] = "sub processing node",
        ["minimum"] = 1,
        ["spare"] = 0
      },
      {
        ["type"] = "input output node",
        ["minimum"] = 1,
        ["spare"] = 2
      },
      {
        ["type"] = "data store node",
        ["minimum"] = 1,
        ["spare"] = 3
      },
    }
  end

  describe("area", function()

    local area = require("model.systemarea")

    it("calculates the area node count", function()

      local nodeCount = area:calculateAreaNodeCount(nodeDefinition())
      assert.are.equal(9, nodeCount)

    end)

    it("stores the definition in the area", function()

      local def = nodeDefinition()
      local myArea = area:create(1, def)
      assert.are.equal(1, myArea.number)
      assert.are.equal(def, myArea.definition)
      assert.are.equal(9, myArea.nodeCount)

    end)

    it("contains a map of certain size", function()

      local myArea = area:create(1, nodeDefinition())
      assert.is_true(myArea.mapsize > 0)
      assert.are.equal(myArea.mapsize, #myArea.map)

    end)

  end)

  describe("main", function()

    local system = require("model.system")

    it("generates from a function node definition", function()

      local mySystem = system:create(1, seed)
      system:generate(mySystem, nodeDefinition)
      assert.are.same(nodeDefinition(), mySystem.areas[1].definition)

    end)

    it("stores new system size and seed", function()

      local mySystem = system:create(1, seed)
      assert.are.equal(1, mySystem.size)
      assert.are.equal(seed, mySystem.seed)

    end)

    it("generates areas within the system", function()

      local mySystem = system:create(1, seed)
      local def = nodeDefinition()
      system:generate(mySystem, def)
      assert.are.equal(1, #mySystem.areas)
      assert.are.equal(def, mySystem.areas[1].definition)

    end)

  end)

end)
