system = require("system")
sysobj = system:create(2, os.time())
system:generate(sysobj)
system:print(sysobj)
