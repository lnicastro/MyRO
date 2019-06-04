#@ONERR_DIE|Database @DB@ does not exists|
USE @DB@//


#@ONERR_IGNORE|Cannot grant privileges on  @DB@.@VIEW@_long TO @USER@@@HOST@|
GRANT SELECT, INSERT, UPDATE, DELETE ON @DB@.@VIEW@_long TO @USER@@@HOST@//

#@ONERR_IGNORE|Cannot grant privileges on  @DB@.@VIEW@_fmtlong TO @USER@@@HOST@|
GRANT SELECT, INSERT, UPDATE, DELETE ON @DB@.@VIEW@_fmtlong TO @USER@@@HOST@//

#@ONERR_IGNORE|Cannot grant privileges on @DB@.@VIEW@_ls TO @USER@@@HOST@|
GRANT SELECT                         ON @DB@.@VIEW@_ls TO @USER@@@HOST@//

#@ONERR_DIE|Cannot grant privileges on  @DB@.@VIEW@ TO @USER@@@HOST@|
GRANT SELECT, INSERT, UPDATE, DELETE ON @DB@.@VIEW@ TO @USER@@@HOST@//


##@ONERR_DIE|Cannot grant select privilege on myro.t_tbl to @USER@@@HOST@|
#GRANT SELECT  ON myro.t_tbl    TO @USER@@@HOST@//
#
##@ONERR_DIE|Cannot grant select privilege on myro.t_usr to @USER@@@HOST@|
#GRANT SELECT  ON myro.t_usr    TO @USER@@@HOST@//
#
##@ONERR_DIE|Cannot grant select privilege on myro.t_grp to @USER@@@HOST@|
#GRANT SELECT  ON myro.t_grp    TO @USER@@@HOST@//
#
##@ONERR_DIE|Cannot grant select privilege on myro.t_usrgrp to @USER@@@HOST@|
#GRANT SELECT  ON myro.t_usrgrp TO @USER@@@HOST@//

#@ONERR_IGNORE||
FLUSH PRIVILEGES//

