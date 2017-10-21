local system = require("system")
local sysobj = system:create(4, os.time())
system:generate(sysobj)
system:print(sysobj)
