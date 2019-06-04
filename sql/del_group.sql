#@ONERR_DIE|Database myro does not exists|
USE myro//

#@ONERR_DIE|Cannot update table myro.grp|
DELETE FROM myro.grp WHERE grp = '@GROUP@'//
