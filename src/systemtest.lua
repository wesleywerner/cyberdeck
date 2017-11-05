local system = require("model.system")
local sysobj = system:create(1, os.time())
system:generate(sysobj)
system:print(sysobj)
