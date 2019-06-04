#@ONERR_DIE|Database @DB@ does not exists|
USE @DB@//



#@ONERR_DIE|Cannot drop view @VIEW@_ls|
DROP VIEW IF EXISTS @DB@.@VIEW@_ls//

#@ONERR_IGNORE|Cannot drop view @VIEW@_long|
DROP VIEW IF EXISTS @DB@.@VIEW@_long//

#@ONERR_IGNORE|Cannot drop view @VIEW@_fmtlong|
DROP VIEW IF EXISTS @DB@.@VIEW@_fmtlong//

#@ONERR_IGNORE|Cannot drop view @VIEW@|
DROP VIEW IF EXISTS @DB@.@VIEW@//

#@ONERR_DIE|Cannot drop trigger myti_@TABLE@|
DROP TRIGGER @DB@.myti_@TABLE@//

#@ONERR_DIE|Cannot drop trigger mytu_@TABLE@|
DROP TRIGGER @DB@.mytu_@TABLE@//

#@ONERR_DIE|Cannot drop trigger mytd_@TABLE@|
DROP TRIGGER @DB@.mytd_@TABLE@//


#
# Non cancelliamo i campi per evitare possibili perdite di dati
#
##@ONERR_DIE|Cannot alter table @TABLE@|
#ALTER TABLE @DB@.@TABLE@ 
#  DROP COLUMN my_perm,
#  DROP COLUMN my_gid,
#  DROP COLUMN my_uid//


#@ONERR_DIE|Cannot update table myro.tbl|
DELETE FROM myro.tbl WHERE db = '@DB@' AND name = '@TABLE@'//
