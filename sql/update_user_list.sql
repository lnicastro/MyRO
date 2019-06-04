#@ONERR_DIE|Cannot insert into table myro.grp|
INSERT IGNORE INTO myro.grp(grp, descr) 
SELECT DISTINCT user, user FROM mysql.user 
WHERE (user != ''   AND   user != '%')//

#@ONERR_DIE|Cannot insert into table myro.usr|
INSERT IGNORE INTO myro.usr(usr) 
SELECT DISTINCT user FROM mysql.user
WHERE (user != ''   AND   user != '%')//

#@ONERR_DIE|Cannot update table myro.usr|
UPDATE myro.usr SET su = 1 WHERE usr = 'root'//

#@ONERR_DIE|Cannot update table myro.usr|
UPDATE myro.usr SET defgid = myro.grp2gid(usr)//


##  #@ONERR_DIE|Cannot insert into table myro.usrgrp|
##  INSERT IGNORE INTO myro.usrgrp(uid, gid) SELECT A.uid, B.gid FROM myro.usr AS A JOIN myro.grp AS B//
##  
##  #@ONERR_DIE|Cannot insert update table myro.usrgrp|
##  REPLACE INTO myro.usrgrp SELECT uid, defgid AS gid FROM myro.usr//

#@ONERR_DIE|Cannot delete from table myro.usr|
DELETE myro.usr 
  FROM myro.usr LEFT JOIN mysql.user 
  ON myro.usr.usr = mysql.user.user
  WHERE mysql.user.user IS NULL//
