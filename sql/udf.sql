#@ONERR_DIE|Database myro does not exists|
USE myro//



DROP FUNCTION  IF EXISTS myro.grp2gid//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.grp2gid(p_grp CHAR(50)) RETURNS TINYINT UNSIGNED
  NOT DETERMINISTIC
  BEGIN
    RETURN (SELECT gid FROM myro.grp WHERE grp=p_grp);
  END//



DROP FUNCTION  IF EXISTS myro.gid2grp//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.gid2grp(p_gid TINYINT UNSIGNED) RETURNS CHAR(50)
  NOT DETERMINISTIC
  BEGIN
	RETURN (SELECT grp FROM myro.grp WHERE gid=p_gid);
  END//



DROP FUNCTION  IF EXISTS myro.usr2uid//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.usr2uid(p_usr CHAR(50)) RETURNS TINYINT UNSIGNED
  NOT DETERMINISTIC
  BEGIN
    RETURN (SELECT uid FROM myro.usr WHERE usr=p_usr);
  END//



DROP FUNCTION  IF EXISTS myro.uid2usr//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.uid2usr(p_uid TINYINT UNSIGNED) RETURNS CHAR(50)
  NOT DETERMINISTIC
  BEGIN
	RETURN (SELECT usr FROM myro.usr WHERE uid=p_uid);
  END//



DROP FUNCTION  IF EXISTS myro.usr_email//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.usr_email(p_usr CHAR(50)) RETURNS CHAR(50)
  NOT DETERMINISTIC
  BEGIN
    RETURN (SELECT email FROM myro.usr WHERE usr=p_usr);
  END//



DROP FUNCTION  IF EXISTS myro.usr_descr//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.usr_descr(p_usr CHAR(50)) RETURNS char(50)
  NOT DETERMINISTIC
  BEGIN
    RETURN (SELECT descr FROM myro.usr WHERE usr=p_usr);
  END//




DROP FUNCTION  IF EXISTS myro.myuser//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.myuser() RETURNS CHAR(50)
    NOT DETERMINISTIC
    RETURN SUBSTRING_INDEX(user(),_utf8'@',1)//



DROP FUNCTION  IF EXISTS myro.is_root//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.is_root() RETURNS BOOL
    NOT DETERMINISTIC
    BEGIN
	IF (myro.myuser() = 'root') THEN
          RETURN 1;
        ELSE
          RETURN 0;
        END IF;
    END//    



DROP FUNCTION  IF EXISTS myro.uid//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.uid() RETURNS TINYINT UNSIGNED
    NOT DETERMINISTIC
    BEGIN
       SET @count = @count + 1;
       RETURN (SELECT uid FROM myro.usr WHERE usr=myro.myuser());
    END//



DROP FUNCTION  IF EXISTS myro.uid2defgid//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.uid2defgid(p_uid TINYINT UNSIGNED) RETURNS TINYINT UNSIGNED
    NOT DETERMINISTIC
    RETURN (SELECT defgid FROM myro.usr WHERE uid=p_uid)//


DROP FUNCTION  IF EXISTS myro.usr2defgid//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.usr2defgid(p_usr CHAR(50)) RETURNS TINYINT UNSIGNED
    NOT DETERMINISTIC
    RETURN (SELECT myro.uid2defgid(myro.usr2uid(p_usr)))//



DROP FUNCTION  IF EXISTS myro.defgid//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.defgid() RETURNS TINYINT UNSIGNED
    NOT DETERMINISTIC
    RETURN myro.uid2defgid(myro.uid())//



DROP FUNCTION  IF EXISTS myro.defgrp//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.defgrp() RETURNS CHAR(50)
    NOT DETERMINISTIC
    RETURN myro.gid2grp(myro.defgid())//



DROP FUNCTION  IF EXISTS myro.uid2defperm//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.uid2defperm(p_uid TINYINT UNSIGNED) RETURNS TINYINT UNSIGNED
    NOT DETERMINISTIC
    RETURN (SELECT defperm FROM myro.usr WHERE uid=p_uid)//



DROP FUNCTION  IF EXISTS myro.defperm//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.defperm() RETURNS TINYINT UNSIGNED
    NOT DETERMINISTIC
    RETURN myro.uid2defperm(myro.uid())//



DROP FUNCTION  IF EXISTS myro.is_su//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.is_su(p_uid TINYINT UNSIGNED) RETURNS BOOL
    NOT DETERMINISTIC
    BEGIN
      DECLARE b BOOL;
      SET b = (SELECT su FROM myro.usr WHERE uid=p_uid);
      IF ISNULL(b) THEN
        RETURN 0;
      ELSE
        RETURN b;
      END IF;
    END//



DROP FUNCTION  IF EXISTS myro.su//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.su() RETURNS BOOL
    NOT DETERMINISTIC
    BEGIN
      DECLARE b BOOL;
      SET b = myro.is_su(myro.uid()) + myro.is_root();
      SET @count = @count + 1;
      RETURN b;
    END//



DROP FUNCTION  IF EXISTS myro.listGroups//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.listGroups(p_uid TINYINT UNSIGNED) RETURNS VARCHAR(200)
   NOT DETERMINISTIC
   BEGIN
     DECLARE a CHAR(50);
     DECLARE res VARCHAR(200);
     DECLARE eof INT DEFAULT 0;
     DECLARE c CURSOR FOR SELECT gid FROM myro.usrgrp WHERE uid=p_uid;
     DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET eof = 1;

     OPEN c;
     SET res='';

     REPEAT
       FETCH c INTO a;
       IF ((NOT eof)  AND  (NOT ISNULL(a))) THEN
         SET res = CONCAT(res, CONCAT(myro.gid2grp(a), ' '));
       END IF;
     UNTIL eof END REPEAT;
     CLOSE c;

     RETURN res;
   END//



DROP PROCEDURE IF EXISTS myro.users//
#@ONERR_DIE|Cannot create procedure|
CREATE PROCEDURE myro.users() 
   NOT DETERMINISTIC
   BEGIN
     SELECT uid, usr, su, descr, email, defgid, 
            myro.gid2grp(defgid) as defgrp,
            myro.listGroups(uid) as addgrp
            FROM myro.usr;
   END//



DROP PROCEDURE IF EXISTS myro.groups//
#@ONERR_DIE|Cannot create procedure|
CREATE PROCEDURE myro.groups()
   NOT DETERMINISTIC
   BEGIN
     SELECT gid, grp, descr FROM myro.grp;
   END//




DROP FUNCTION  IF EXISTS myro.uid_member_of_anygroup//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.uid_member_of_anygroup(p_uid TINYINT UNSIGNED)
  RETURNS BOOLEAN
   NOT DETERMINISTIC
   BEGIN
     SET @count = @count + 1;
     RETURN (SELECT COUNT(*) FROM myro.usrgrp WHERE uid = p_uid AND gid = 1);
   END//


DROP FUNCTION  IF EXISTS myro.uid_member_of_gid//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.uid_member_of_gid(p_uid TINYINT UNSIGNED, p_gid TINYINT UNSIGNED)
   RETURNS BOOLEAN
   NOT DETERMINISTIC
   BEGIN
     IF (myro.uid_member_of_anygroup(p_uid)) THEN
       RETURN 1;
     ELSE
       RETURN (SELECT COUNT(*) FROM myro.usrgrp WHERE uid = p_uid AND gid = p_gid);
     END IF;
   END//




DROP FUNCTION  IF EXISTS myro.uid_member_of_grp//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.uid_member_of_grp(p_uid TINYINT UNSIGNED, p_grp CHAR(50))
    RETURNS BOOLEAN
    NOT DETERMINISTIC
    RETURN myro.uid_member_of_gid(p_uid, myro.grp2gid(p_grp))//



DROP FUNCTION  IF EXISTS myro.usr_member_of_gid//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.usr_member_of_gid(p_usr CHAR(50), p_gid TINYINT UNSIGNED) 
    RETURNS BOOLEAN
    NOT DETERMINISTIC
    RETURN myro.uid_member_of_gid(myro.usr2uid(p_usr), p_gid)//



DROP FUNCTION  IF EXISTS myro.usr_member_of_grp//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.usr_member_of_grp(p_usr CHAR(50), p_grp CHAR(50)) 
    RETURNS BOOLEAN
    NOT DETERMINISTIC
    RETURN myro.uid_member_of_gid(myro.usr2uid(p_usr), myro.grp2gid(p_grp))//


DROP FUNCTION  IF EXISTS myro_error//
#@ONERR_DIE|Cannot create function myro_error|
CREATE FUNCTION myro_error RETURNS INTEGER SONAME 'libmyro.so'//

DROP FUNCTION  IF EXISTS myro_Count//
#@ONERR_DIE|Cannot create function myro_Count|
CREATE FUNCTION myro_Count RETURNS INTEGER SONAME 'libmyro.so'//

DROP FUNCTION  IF EXISTS myro_userValue//
#@ONERR_DIE|Cannot create function myro_userValue|
CREATE FUNCTION myro_userValue RETURNS INTEGER SONAME 'libmyro.so'//


DROP FUNCTION  IF EXISTS myro_setIdentity//
#@ONERR_DIE|Cannot create function myro_setIdentity|
CREATE FUNCTION myro_setIdentity RETURNS INTEGER SONAME 'libmyro.so'//

DROP FUNCTION  IF EXISTS myro_setGid//
#@ONERR_DIE|Cannot create function myro_setGid|
CREATE FUNCTION myro_setGid RETURNS INTEGER SONAME 'libmyro.so'//

DROP FUNCTION  IF EXISTS myro_granted//
#@ONERR_DIE|Cannot create function myro_granted|
CREATE FUNCTION myro_granted RETURNS INTEGER SONAME 'libmyro.so'//


DROP FUNCTION IF EXISTS myro.setIdentity//

#@ONERR_DIE|Cannot create function myro.setIdentity|
CREATE FUNCTION myro.setIdentity(c INT)
  RETURNS INTEGER
  NOT DETERMINISTIC SQL SECURITY INVOKER
  BEGIN
    DECLARE luid INT;
    DECLARE lgid INT;
    DECLARE lsu  INT;
    DECLARE lma  INT;
    DECLARE dummy INT;
    DECLARE eof INT DEFAULT 0;
    DECLARE d CURSOR FOR SELECT gid FROM myro.usrgrp WHERE uid=luid;
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET eof = 1;

    IF (c > 0) THEN
      RETURN 1;
    END IF;

    SET luid = myro.uid();
    SET lsu  = myro.is_su(luid);
    SET lma  = myro.uid_member_of_anygroup(luid);
    SET dummy = myro_setIdentity(luid, lsu, lma);

    #Clear GID table
    SET dummy = myro_setGid(-1); 

    OPEN d;
    REPEAT
      FETCH d INTO lgid;
       IF ((NOT eof)  AND  (NOT ISNULL(lgid))) THEN
         SET dummy = myro_setGid(lgid);
       END IF;
    UNTIL eof END REPEAT;
    CLOSE d;

    RETURN 1;
  END//



DROP FUNCTION  IF EXISTS myro.assign_usr_to_grp//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.assign_usr_to_grp(p_usr CHAR(50), p_grp CHAR(50), member BOOLEAN) 
    RETURNS INTEGER
    NOT DETERMINISTIC SQL SECURITY INVOKER
    BEGIN
      DECLARE uid INT;
      DECLARE gid INT;

      IF (! myro.su()) THEN
        SET uid = myro_error('Only Super-Users can call myro.assign_usr_to_grp');
      END IF;

     SET uid = myro.usr2uid(p_usr);
     IF ISNULL(uid) THEN 
       SET uid = myro_error('User does not exists');
     END IF;

     SET gid = myro.grp2gid(p_grp);
     IF ISNULL(gid) THEN 
        SET uid = myro_error('Group does not exists');
     END IF;

     INSERT IGNORE INTO myro.usrgrp VALUES(uid, gid);

     RETURN 1;
    END//


    

##DROP PROCEDURE IF EXISTS myro.userdel//
###@ONERR_DIE|Cannot create procedure|
##CREATE PROCEDURE myro.userdel(IN p_usr CHAR(50))
##    NOT DETERMINISTIC SQL SECURITY INVOKER
##    BEGIN
##      DECLARE id TINYINT UNSIGNED;
##      IF myro.su() THEN 
##        SET id = myro.usr2uid(p_usr);
##
##        DELETE FROM myro.usr WHERE uid=id;
##        DELETE FROM myro.usrgrp WHERE uid=id;      
##        SELECT myro.loadpriv();
##      ELSE
##        SELECT myro_error('Only Super-Users can call myro.userdel');
##      END IF;
##    END//


DROP PROCEDURE IF EXISTS myro.groupdel//
#@ONERR_DIE|Cannot create procedure|
CREATE PROCEDURE myro.groupdel(IN p_grp CHAR(50))
    NOT DETERMINISTIC SQL SECURITY INVOKER
    BEGIN
      DECLARE id TINYINT UNSIGNED;
      IF myro.su() THEN 
        SET id = myro.grp2gid(p_grp);
 
        DELETE FROM myro.grp WHERE gid=id;
        DELETE FROM myro.usrgrp WHERE gid=id;      
        SELECT myro.loadpriv();
      ELSE
        SELECT myro_error('Only Super-Users can call myro.groupdel');
      END IF;
    END//



DROP FUNCTION IF EXISTS myro.chkPerm//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.chkPerm(
       p_uid TINYINT UNSIGNED, 
       my_uid TINYINT UNSIGNED, my_gid TINYINT UNSIGNED, my_perm TINYINT UNSIGNED,
       p_what CHAR(1)) 
  RETURNS BOOLEAN
  NOT DETERMINISTIC
  BEGIN
    IF (p_what = 'r') THEN
      IF (
          ((my_perm &  2) != 0    AND    my_uid = p_uid)                          OR
          ((my_perm &  8) != 0    AND    myro.uid_member_of_gid(p_uid, my_gid))   OR
          ((my_perm & 32) != 0)
         ) THEN
         RETURN TRUE;
      END IF;
    END IF;

    IF (p_what = 'w') THEN
      IF (
          ((my_perm &  1) != 0    AND    my_uid = p_uid)                          OR
          ((my_perm &  4) != 0    AND    myro.uid_member_of_gid(p_uid, my_gid))   OR
          ((my_perm & 16) != 0)
         ) THEN
         RETURN TRUE;
      END IF;
    END IF;

    RETURN FALSE; 
  END//


DROP FUNCTION IF EXISTS myro.fmtPerm//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.fmtPerm(p_perm TINYINT UNSIGNED) RETURNS CHAR(6)
  NOT DETERMINISTIC
  BEGIN
    DECLARE ret CHAR(6);

    SET ret = '';

    #User
    IF (p_perm & 2)  THEN SET ret = CONCAT(ret, 'r');
    ELSE                  SET ret = CONCAT(ret, '-'); END IF;
    IF (p_perm & 1)  THEN SET ret = CONCAT(ret, 'w');
    ELSE                  SET ret = CONCAT(ret, '-'); END IF;

    #Group
    IF (p_perm & 8)  THEN SET ret = CONCAT(ret, 'r');
    ELSE                  SET ret = CONCAT(ret, '-'); END IF;
    IF (p_perm & 4)  THEN SET ret = CONCAT(ret, 'w');
    ELSE                  SET ret = CONCAT(ret, '-'); END IF;

    #Others
    IF (p_perm & 32) THEN SET ret = CONCAT(ret, 'r');
    ELSE                  SET ret = CONCAT(ret, '-'); END IF;
    IF (p_perm & 16) THEN SET ret = CONCAT(ret, 'w');
    ELSE                  SET ret = CONCAT(ret, '-'); END IF;

    RETURN ret;
  END//


DROP FUNCTION  IF EXISTS myro.perm//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.perm(p_perm CHAR(6)) RETURNS TINYINT UNSIGNED 
  NOT DETERMINISTIC
  BEGIN
    DECLARE ret TINYINT UNSIGNED;
    SET ret = 0;

    #User
    IF (SUBSTR(p_perm, 1, 1) = 'r') THEN SET ret = ret +  2; END IF;
    IF (SUBSTR(p_perm, 2, 1) = 'w') THEN SET ret = ret +  1; END IF;

    #Group
    IF (SUBSTR(p_perm, 3, 1) = 'r') THEN SET ret = ret +  8; END IF;
    IF (SUBSTR(p_perm, 4, 1) = 'w') THEN SET ret = ret +  4; END IF;

    #Others
    IF (SUBSTR(p_perm, 5, 1) = 'r') THEN SET ret = ret + 32; END IF;
    IF (SUBSTR(p_perm, 6, 1) = 'w') THEN SET ret = ret + 16; END IF;

    RETURN ret;
  END//



DROP PROCEDURE IF EXISTS myro.print_priv//
#@ONERR_DIE|Cannot create procedure|
CREATE PROCEDURE myro.print_priv(IN p_usr CHAR(50))
BEGIN

  IF (p_usr = '') THEN
    SELECT 'mysql.user' AS Perm_Table, 'Select_priv' AS Perm_Column, 'a' AS Code UNION
    SELECT 'mysql.user', 'Insert_priv'		   , 'b' UNION 
    SELECT 'mysql.user', 'Update_priv'		   , 'c' UNION 
    SELECT 'mysql.user', 'Delete_priv'		   , 'd' UNION 
    SELECT 'mysql.user', 'Create_priv'		   , 'e' UNION 
    SELECT 'mysql.user', 'Drop_priv'		   , 'f' UNION 
    SELECT 'mysql.user', 'Reload_priv'		   , 'g' UNION 
    SELECT 'mysql.user', 'Shutdown_priv' 		   , 'h' UNION 
    SELECT 'mysql.user', 'Process_priv' 		   , 'i' UNION 
    SELECT 'mysql.user', 'File_priv' 		   , 'j' UNION 
    SELECT 'mysql.user', 'Grant_priv' 		   , 'k' UNION 
    SELECT 'mysql.user', 'References_priv' 	   , 'l' UNION 
    SELECT 'mysql.user', 'Index_priv' 		   , 'm' UNION 
    SELECT 'mysql.user', 'Alter_priv' 		   , 'n' UNION 
    SELECT 'mysql.user', 'Show_db_priv' 		   , 'o' UNION 
    SELECT 'mysql.user', 'Super_priv' 		   , 'p' UNION 
    SELECT 'mysql.user', 'Create_tmp_table_priv' 	   , 'q' UNION 
    SELECT 'mysql.user', 'Lock_tables_priv' 	   , 'r' UNION 
    SELECT 'mysql.user', 'Execute_priv' 		   , 's' UNION 
    SELECT 'mysql.user', 'Repl_slave_priv' 	   , 't' UNION 
    SELECT 'mysql.user', 'Repl_client_priv' 	   , 'u' UNION 
    SELECT 'mysql.user', 'Create_view_priv' 	   , 'v' UNION 
    SELECT 'mysql.user', 'Show_view_priv' 	   , 'w' UNION
    SELECT 'mysql.user', 'Create_routine_priv' 	   , 'x' UNION 
    SELECT 'mysql.user', 'Alter_routine_priv' 	   , 'y' UNION 
    SELECT 'mysql.user', 'Create_user_priv' 	   , 'z' UNION 
    SELECT 'mysql.user', 'Event_priv' 		   , 'A' UNION 
    SELECT 'mysql.user', 'Trigger_priv'              , 'B';
  
  
    SELECT 'mysql.db' AS Perm_Table, 'Select_priv' AS Perm_Column, 'a' AS Code  UNION
    SELECT 'mysql.db', 'Insert_priv'           , 'b'  UNION
    SELECT 'mysql.db', 'Update_priv'           , 'c'  UNION
    SELECT 'mysql.db', 'Delete_priv'           , 'd'  UNION
    SELECT 'mysql.db', 'Create_priv'           , 'e'  UNION
    SELECT 'mysql.db', 'Drop_priv'     	     , 'f'  UNION
    SELECT 'mysql.db', 'Grant_priv'      	     , 'g'  UNION
    SELECT 'mysql.db', 'References_priv'       , 'h'  UNION
    SELECT 'mysql.db', 'Index_priv'      	     , 'i'  UNION
    SELECT 'mysql.db', 'Alter_priv'      	     , 'j'  UNION
    SELECT 'mysql.db', 'Create_tmp_table_priv' , 'k'  UNION    
    SELECT 'mysql.db', 'Lock_tables_priv'      , 'l'  UNION
    SELECT 'mysql.db', 'Create_view_priv'      , 'm'  UNION
    SELECT 'mysql.db', 'Show_view_priv'        , 'n'  UNION
    SELECT 'mysql.db', 'Create_routine_priv'   , 'o'  UNION     
    SELECT 'mysql.db', 'Alter_routine_priv'    , 'p'  UNION  
    SELECT 'mysql.db', 'Execute_priv'          , 'q'  UNION
    SELECT 'mysql.db', 'Event_priv'      	     , 'r'  UNION
    SELECT 'mysql.db', 'Trigger_priv'          , 's';
  
    SELECT 'mysql.tables_priv' AS Perm_Table, 'Table_name' AS Perm_Column, 'a' AS Code  UNION
    SELECT 'mysql.tables_priv', 'Grantor'              , 'b'  UNION
    SELECT 'mysql.tables_priv', 'Timestamp'            , 'c'  UNION
    SELECT 'mysql.tables_priv', 'Table_priv'           , 'd'  UNION
    SELECT 'mysql.tables_priv', 'Column_priv'          , 'e';
  
    SELECT 'mysql.columns_priv' AS Perm_Table, 'Table_name' AS Perm_Column, 'a' AS Code  UNION
    SELECT 'mysql.columns_priv', 'Column_name'          , 'b'  UNION
    SELECT 'mysql.columns_priv', 'Timestamp'            , 'c'  UNION
    SELECT 'mysql.columns_priv', 'Column_priv'          , 'd';
  
    SELECT 'mysql.procs_priv' AS Perm_Table, 'Routine_name' AS Perm_Column, 'a' AS Code  UNION
    SELECT 'mysql.procs_priv', 'Routine_type'       , 'b'  UNION
    SELECT 'mysql.procs_priv', 'Grantor'            , 'c'  UNION
    SELECT 'mysql.procs_priv', 'Proc_priv'          , 'd'  UNION
    SELECT 'mysql.procs_priv', 'Timestamp'          , 'e';
   
	
  ELSE

    SELECT 'mysql.user', Host, User, 
    CONCAT(
    	Select_priv, Insert_priv, Update_priv, Delete_priv, Create_priv, 
    	Drop_priv, Reload_priv, Shutdown_priv, Process_priv, File_priv, 
          Grant_priv, References_priv, Index_priv, Alter_priv, Show_db_priv, 
          Super_priv, Create_tmp_table_priv, Lock_tables_priv, Execute_priv, 
          Repl_slave_priv, Repl_client_priv, Create_view_priv, Show_view_priv, 
          Create_routine_priv, Alter_routine_priv, Create_user_priv, Event_priv, 
          Trigger_priv
    	) AS abcdefghijklmnopqrstuvwxyzAB
    FROM mysql.user
    WHERE user LIKE p_usr ORDER BY user, host;
    
    SELECT 'mysql.db', Host, Db, User, 
    CONCAT(Select_priv, Insert_priv, Update_priv, Delete_priv, Create_priv, Drop_priv,
           Grant_priv, References_priv, Index_priv, Alter_priv, Create_tmp_table_priv,
           Lock_tables_priv, Create_view_priv, Show_view_priv, Create_routine_priv,   
           Alter_routine_priv, Execute_priv, Event_priv, Trigger_priv)
           AS abcdefghijklmnopqrs
    FROM mysql.db
    WHERE user LIKE p_usr ORDER BY user, host, Db;
    
    SELECT 'mysql.tables_priv', Host, Db, User,
    CONCAT(Table_name, Grantor, Timestamp, Table_priv, Column_priv) AS abcde
    FROM mysql.tables_priv
    WHERE user LIKE p_usr ORDER BY user, host, Db, Table_name;
    
    SELECT'mysql.columns_priv',  Host, Db, User,
    CONCAT(Table_name, Column_name, Timestamp, Column_priv) AS abcd
    FROM mysql.columns_priv
    WHERE user LIKE p_usr ORDER BY user, host, Db, Table_name, Column_name;
    
    SELECT 'mysql.procs_priv', Host, Db, User,
    CONCAT(Routine_name, Routine_type, Grantor, Proc_priv, Timestamp) AS abcde
    FROM mysql.procs_priv
    WHERE user LIKE p_usr ORDER BY user, host, Db, Routine_name;

  END IF;


  #SELECT 'user'   , mysql.user.*         FROM mysql.user         WHERE user LIKE p_usr ORDER BY user, host;
  #SELECT 'db'     , mysql.db.*           FROM mysql.db           WHERE user LIKE p_usr ORDER BY user, host, Db;
  #SELECT 'tables' , mysql.tables_priv.*  FROM mysql.tables_priv  WHERE user LIKE p_usr ORDER BY user, host, Db, Table_name;
  #SELECT 'columns', mysql.columns_priv.* FROM mysql.columns_priv WHERE user LIKE p_usr ORDER BY user, host, Db, Table_name, Column_name;
  #SELECT 'procs'  , mysql.procs_priv.*   FROM mysql.procs_priv   WHERE user LIKE p_usr ORDER BY user, host, Db, Routine_name;
END//



DROP FUNCTION  IF EXISTS myro.user_can_access//
#@ONERR_DIE|Cannot create function|
CREATE FUNCTION myro.user_can_access(p_usr CHAR(50), p_db CHAR(50), p_tbl CHAR(50)) RETURNS BOOL
BEGIN
  DECLARE c INT;
  DECLARE tmp CHAR(30);

  SET tmp = CONCAT('\'', CONCAT(p_usr, '\'%'));

  SET c = (SELECT count(*) FROM information_schema.USER_PRIVILEGES 
           WHERE GRANTEE LIKE tmp);
  IF (c = 0) THEN SET c = myro_error('User name does not exists.'); END IF;


  SET c = (SELECT count(*) FROM information_schema.SCHEMA_PRIVILEGES 
           WHERE GRANTEE LIKE tmp AND TABLE_SCHEMA = p_db);
  IF (c > 0) THEN RETURN 1; END IF;


  SET c = (SELECT count(*) FROM information_schema.TABLE_PRIVILEGES 
           WHERE GRANTEE LIKE tmp AND TABLE_SCHEMA = p_db AND TABLE_NAME = p_tbl);
  IF (c > 0) THEN RETURN 2; END IF;


  SET c = (SELECT count(*) FROM information_schema.COLUMN_PRIVILEGES 
           WHERE GRANTEE LIKE tmp AND TABLE_SCHEMA = p_db AND TABLE_NAME = p_tbl);
  IF (c > 0) THEN RETURN 3; END IF;

  RETURN 0;
END//



DROP PROCEDURE myro.trigger_insert//
#@ONERR_DIE|Cannot create procedure|
CREATE PROCEDURE myro.trigger_insert(INOUT my_uid TINYINT UNSIGNED, 
                                     INOUT my_gid TINYINT UNSIGNED, 
                                     INOUT my_perm TINYINT UNSIGNED)
  NOT DETERMINISTIC
  BEGIN
    DECLARE luid INTEGER;
    SET luid = myro.uid();

    IF (NOT myro.su()) THEN
      SET my_uid  = NULL;
      SET my_gid  = NULL;
      SET my_perm = NULL;
    END IF;

    IF ISNULL(my_uid)  THEN SET my_uid  = luid;                   END IF;
    IF ISNULL(my_gid)  THEN SET my_gid  = myro.uid2defgid(luid);  END IF;
    IF ISNULL(my_perm) THEN SET my_perm = myro.uid2defperm(luid); END IF;
  END//    


DROP PROCEDURE myro.trigger_update//
#@ONERR_DIE|Cannot create procedure|
CREATE PROCEDURE myro.trigger_update(IN my_uid TINYINT UNSIGNED, 
                                     IN my_gid TINYINT UNSIGNED, 
                                     IN my_perm TINYINT UNSIGNED)
  NOT DETERMINISTIC
  BEGIN
    DECLARE a INTEGER;
    IF (NOT myro.su()   AND
        NOT myro.chkPerm(myro.uid(), my_uid, my_gid, my_perm, 'w')) THEN
      SET a = myro_error("Update access denied");
    END IF;
  END//    

DROP PROCEDURE myro.trigger_delete//
#@ONERR_DIE|Cannot create procedure|
CREATE PROCEDURE myro.trigger_delete(IN my_uid TINYINT UNSIGNED, 
                                     IN my_gid TINYINT UNSIGNED, 
                                     IN my_perm TINYINT UNSIGNED)
  NOT DETERMINISTIC
  BEGIN
    DECLARE a INTEGER;
    IF (NOT myro.su()   AND
        NOT myro.chkPerm(myro.uid(), my_uid, my_gid, my_perm, 'w')) THEN
      SET a = myro_error("Delete access denied");
    END IF;
  END//    



-- LN 18/02/2010: derived from myro.row_count: changed input params order
-- LN 17/02/2012: increased id, etc. from TINYINT to SMALLINT

DROP PROCEDURE  IF EXISTS myro.rows_count//
#@ONERR_DIE|Cannot create procedure|
CREATE PROCEDURE myro.rows_count(IN in_db VARCHAR(50), IN tabview VARCHAR(50), IN twhat VARCHAR(200), IN twhere VARCHAR(200), IN tusr VARCHAR(50))
  NOT DETERMINISTIC
  BEGIN
    DECLARE is_su, is_any_gid, in_usr, in_w BOOL DEFAULT false;
    DECLARE id, the_gid, anyg_gid, extra_gid, perm SMALLINT;
    DECLARE n_gids TINYINT DEFAULT 0;
    DECLARE orig_tab CHAR(50) DEFAULT '';
    DECLARE the_what VARCHAR(200) DEFAULT '*';
    DECLARE the_usr CHAR(50) DEFAULT (SELECT SUBSTRING_INDEX(user(),_utf8'@',1));
    DECLARE l_sql VARCHAR(500);
    DECLARE eof INT DEFAULT 0;
    DECLARE c CURSOR FOR SELECT gid FROM myro.usrgrp WHERE uid=myro.usr2uid(tusr);
    DECLARE d CURSOR FOR SELECT gid FROM myro.usrgrp WHERE uid=myro.usr2uid(the_usr);
    DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET eof = 1;

    IF (twhat != '') THEN
      SET the_what = twhat;
    END IF;

    IF (tusr != '') THEN
      SET the_usr = tusr;
      SET in_usr = true;
    END IF;

    SELECT uid, defgid INTO id, the_gid FROM myro.usr where usr=the_usr;
    SELECT COUNT(gid) INTO n_gids from myro.usrgrp where uid=id;
      
    SET is_su = myro.is_su(id);
    SELECT gid INTO anyg_gid FROM myro.grp WHERE grp='anygroup';
    SET is_any_gid = (myro.uid_member_of_anygroup(id) OR the_gid = anyg_gid);
    SELECT name INTO orig_tab FROM myro.tbl where db=in_db and viewname=tabview;

    SET l_sql=CONCAT('SELECT COUNT(',the_what,') AS Nrows FROM ', in_db, '.',orig_tab);
    IF (twhere != '') THEN
      SET in_w = true;
      IF (INSTR(twhere,'WHERE')) THEN
        SET l_sql=CONCAT(l_sql,' ',twhere);
      ELSE
        SET l_sql=CONCAT(l_sql,' WHERE ',twhere);
      END IF;
    END IF;

    IF (is_su) THEN
      SET @sql=l_sql;
    ELSE
      IF (in_w) THEN
        SET l_sql=CONCAT(l_sql, ' AND ( ');
      ELSE
        SET l_sql=CONCAT(l_sql, ' WHERE ( ');
      END IF;
      SET l_sql=CONCAT(l_sql, '((my_perm & 2) AND my_uid = ', id, ') OR (');
      SET l_sql=CONCAT(l_sql, '(my_perm & 8) AND ', is_any_gid, ') OR ');
      SET l_sql=CONCAT(l_sql, '(my_perm >= 32)');
      IF (n_gids > 0) THEN
        IF (in_usr) THEN
          OPEN c;

          REPEAT
          FETCH c INTO extra_gid;
          IF NOT eof THEN
            SET l_sql=CONCAT(l_sql, ' OR (my_gid = ', extra_gid, ')');
          END IF;
          UNTIL eof END REPEAT;
          CLOSE c;
        ELSE
          OPEN d;

          REPEAT
          FETCH d INTO extra_gid;
          IF NOT eof THEN
            SET l_sql=CONCAT(l_sql, ' OR (my_gid = ', extra_gid, ')');
          END IF;
          UNTIL eof END REPEAT;
          CLOSE d;
        END IF;
      END IF;

      SET l_sql=CONCAT(l_sql, ' )');

      SET @sql=l_sql;
    END IF;
    PREPARE s1 FROM @sql;
    EXECUTE s1;
    DEALLOCATE PREPARE s1;
  END//
