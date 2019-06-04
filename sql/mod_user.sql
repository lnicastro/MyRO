#@ONERR_DIE|Database myro does not exists|
USE myro//

#@ONERR_DIE|Cannot update table myro.usr|
UPDATE myro.usr
SET su=@SU@,
    defgid=myro.grp2gid('@GROUP@'),
    descr='@DESCR@',
    email='@EMAIL@'
WHERE uid = usr2uid('@USER@')//

#@ONERR_DIE|An error occurred during SELECT myro.assign_usr_to_grp('@USER@', '@GROUP@', 1)|
SELECT myro.assign_usr_to_grp('@USER@', '@GROUP@', 1)//
