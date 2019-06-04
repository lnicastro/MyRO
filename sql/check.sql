#@ONERR_DIE|Database myro does not exists|
USE myro//

#@ONERR_DIE|Table myro does not exists|
SELECT * FROM myro LIMIT 0//

#@ONERR_DIE|Table tbl does not exists|
SELECT * FROM tbl LIMIT 0//

#@ONERR_DIE|Table usr does not exists|
SELECT * FROM usr LIMIT 0//

#@ONERR_DIE|Table grp does not exists|
SELECT * FROM grp LIMIT 0//

#@ONERR_DIE|Table usrgrp does not exists|
SELECT * FROM usrgrp LIMIT 0//

#@ONERR_DIE|Function myuser does not exists|
SELECT myro.myuser()//

# OBS ##@ONERR_DIE|Function loadpriv does not exists|
# OBS #SELECT myro.loadpriv()//



