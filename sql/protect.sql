#@ONERR_DIE|Database @DB@ does not exists|
USE @DB@//

#@ONERR_WARN|Cannot alter table @TABLE@|
ALTER TABLE @DB@.@TABLE@
  ADD COLUMN my_uid   SMALLINT UNSIGNED,
  ADD COLUMN my_gid   SMALLINT UNSIGNED,
  ADD COLUMN my_perm  TINYINT UNSIGNED//

#Adding index to this table give a problem:
# inserting a row and selecting from my_* view gives a wrong result
# the first time is executed, the right result on the second.

#@ONERR_IGNORE||
DROP TRIGGER @DB@.myti_@TABLE@//

#@ONERR_IGNORE||
DROP TRIGGER @DB@.mytu_@TABLE@//

#@ONERR_IGNORE||
DROP TRIGGER @DB@.mytd_@TABLE@//


#@ONERR_DIE|Cannot create trigger @DB@.myti_@TABLE@ on table @DB@.@TABLE@|
CREATE TRIGGER @DB@.myti_@TABLE@ BEFORE INSERT ON @DB@.@TABLE@ FOR EACH ROW
    BEGIN
      CALL myro.trigger_insert(NEW.my_uid, NEW.my_gid, NEW.my_perm);
    END//

#@ONERR_DIE|Cannot create trigger @DB@.mytu_@TABLE@ on table @DB@.@TABLE@|
CREATE TRIGGER @DB@.mytu_@TABLE@ BEFORE UPDATE ON @DB@.@TABLE@ FOR EACH ROW
    BEGIN
      CALL myro.trigger_update(OLD.my_uid, OLD.my_gid, OLD.my_perm);
    END//

#@ONERR_DIE|Cannot create trigger @DB@.mytd_@TABLE@ on table @DB@.@TABLE@|
CREATE TRIGGER @DB@.mytd_@TABLE@ BEFORE DELETE ON @DB@.@TABLE@ FOR EACH ROW
    BEGIN
      CALL myro.trigger_delete(OLD.my_uid, OLD.my_gid, OLD.my_perm);
    END//



#@ONERR_IGNORE||
DROP VIEW IF EXISTS @DB@.@VIEW@//

#@ONERR_DIE|Cannot create view @VIEW@|
CREATE ALGORITHM=MERGE VIEW @DB@.@VIEW@ AS
SELECT @FLIST@
FROM   @TABLE@
WHERE  myro.setIdentity(myro_Count())   AND   myro_granted(my_uid, my_gid, my_perm)//


#         (myro_userValue(IF (myro_Count()=1, myro.su(), 0)))                                         OR
#        ((my_perm &  2) != 0    AND    my_uid = myro_userValue(IF (myro_Count()=1, myro.uid(), 0)))  OR
#         (my_perm >= 32)                                                                             OR
#        ((my_perm &  8) != 0    AND 
#           (
#             (myro_userValue(IF (myro_Count()=1, myro.uid_member_of_anygroup(myro.uid()), 0))) OR
#             (my_gid IN (SELECT gid 
#                         FROM myro.usrgrp 
#                         WHERE uid = myro_userValue(IF (myro_Count()=1, myro.uid(), 0))))
#           )
#        )
#       )//









#@ONERR_DIE|Cannot insert row in myro.tbl|
INSERT INTO myro.tbl(db, name, viewname) VALUES('@DB@', '@TABLE@', '@VIEW@')
  ON DUPLICATE KEY UPDATE viewname='@VIEW@'//





#
#Questa ha un solo problema: non funziona il DELETE perché è una
#query con join. Se questa limitazione di MySQL viene superata si
#potrà usare.
#
#DROP VIEW mcstest;
#CREATE ALGORITHM=MERGE VIEW mcstest AS
#SELECT A.*, B.member
#FROM mcstest AS A INNER JOIN myro.usrgrp AS B
#ON (A.my_gid = B.gid   AND   B.uid = 1)
#WHERE (
#         (myro_userValue(IF (myro_firstTime(), myro.su(), 0)))                                         OR
#        ((my_perm &  2) != 0    AND    my_uid = myro_userValue(IF (myro_firstTime(), myro.uid(), 0)))  OR
#         (my_perm >= 32)                                                                               OR
#        ((my_perm &  8) != 0    AND    (B.member = 1))
#      );
#


#
# Con la join non va bene perche' la view non e' updatabile a causa
#della left join, andrebbe bene con la INNER JOIN ma in questo caso
#non verrebbero presi i record appartenenti ad un gruppo di cui
#l'utente corrente non e' membro, ma che potrebbero essere leggibili
#tramite i permessi "others"
#
#DROP VIEW mcstest;
#CREATE ALGORITHM=MERGE VIEW @DB@.@VIEW@ AS
#SELECT A.*, B.uid
#FROM mcstest AS A INNER JOIN myro.usrgrp AS B
#ON (A.my_gid = B.gid  AND  B.uid IN (myro_userValue(IF (myro_firstTime(), myro.uid(), 0)), NULL))
#WHERE (
#        (my_uid = myro_userValue(IF (myro_firstTime(), myro.uid(), 0))   AND    ((my_perm & 2) != 0))   OR
#                                                                                 (my_perm >= 32)        OR
#        (NOT ISNULL(B.uid)                                               AND    ((my_perm & 8) != 0))  
#      );
#




#
#la versione C richiede la libreria esterna ed il passaggio dei dati
#tramite un file temporaneo, inoltre ogni volta vien cercato il nome
#utente ed i gruppi a cui appartiene
#
#CREATE VIEW @DB@.@VIEW@ AS
#SELECT @TABLE@.*
#FROM @TABLE@
#WHERE (myro_cGranted(user(), my_perm, my_uid, my_gid, 'r') = 1)//
#




#
#Con le UNION (sfrutta gli indici)
#non va bene perche' la view non e' updatabile a causa della union
#
#CREATE VIEW @DB@.@VIEW@ AS
#SELECT * FROM @TABLE@ WHERE (my_uid = myro.uid()   AND    ((my_perm & 2) != 0))
#UNION DISTINCT
#SELECT * FROM @TABLE@ WHERE  (my_perm >= 32)
#UNION DISTINCT
#SELECT STRAIGHT_JOIN A.* 
#FROM   myro.usrgrp AS B INNER JOIN @TABLE@ AS A
#ON     (A.my_gid = B.gid) 
#WHERE  uid = myro.uid() AND ((A.my_perm & 8) != 0)//
#


#
#Con i due campi separati (vedi foglio) non verrebbero utilizzati gli indici
#poiche gli indici non sono ripetuti in tutte le OR
#


