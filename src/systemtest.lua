system = require("system")
sysobj = system:create(1, os.time())
system:generate(sysobj)
system:print(sysobj)
