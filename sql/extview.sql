#@ONERR_DIE|Database @DB@ does not exists|
USE @DB@//


# NOTA: la prossime queries sono identiche alla view principale cambia
#solo la lista dei campi, quindi sono uguali dal FROM in poi


#@ONERR_IGNORE||
DROP VIEW IF EXISTS @DB@.@VIEW@_long//

#@ONERR_DIE|Cannot create view @VIEW@_long|
CREATE ALGORITHM=MERGE VIEW @DB@.@VIEW@_long AS
SELECT 
       my_uid,
       my_gid,
       my_perm,
       @FLIST@
FROM   @TABLE@
WHERE  myro.setIdentity(myro_Count())   AND   myro_granted(my_uid, my_gid, my_perm)//






#@ONERR_IGNORE||
DROP VIEW IF EXISTS @DB@.@VIEW@_fmtlong//

#@ONERR_DIE|Cannot create view @VIEW@_fmtlong|
CREATE ALGORITHM=MERGE VIEW @DB@.@VIEW@_fmtlong AS
SELECT 
       myro.uid2usr(my_uid)     AS my_user,
       myro.gid2grp(my_gid)     AS my_group,
       myro.fmtPerm(my_perm)    AS my_fperm,
       @FLIST@
FROM   @TABLE@
WHERE  myro.setIdentity(myro_Count())   AND   myro_granted(my_uid, my_gid, my_perm)//





#@ONERR_IGNORE||
DROP VIEW IF EXISTS @DB@.@VIEW@_ls//

#@ONERR_DIE|Cannot create view @DB@.@VIEW@_ls|
CREATE VIEW @DB@.@VIEW@_ls AS
SELECT
  myro.uid2usr(my_uid) AS my_user,
  myro.gid2grp(my_gid) AS my_group,
  myro.fmtPerm(my_perm) AS my_fperm,
  count(*) AS count
FROM @DB@.@VIEW@_long
GROUP BY my_uid, my_gid, my_perm
ORDER BY my_user, my_group, my_fperm//
