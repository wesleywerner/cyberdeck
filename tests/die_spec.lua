describe("Die", function()

  local Die = require("die")

  it("roll expected success", function()
    local roll = Die:roll(0)
    if roll.success == true then
      assert.is_true(roll.value > 0)
    elseif roll.critical == true then
      assert.is_true(roll.value == -1)
    else
      assert.is_true(roll.value == 0)
    end
  end)

  it("roll expected failure", function()
    local roll = Die:roll(20)
    if roll.success == true then
      assert.is_true(roll.value > 0)
    elseif roll.critical == true then
      assert.is_true(roll.value == -1)
    else
      assert.is_true(roll.value == 0)
    end
  end)

end)