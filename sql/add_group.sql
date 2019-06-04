#@ONERR_DIE|Database myro does not exists|
USE myro//

#@ONERR_DIE|Cannot insert in table myro.grp|
INSERT IGNORE INTO myro.grp(grp, descr) VALUES ('@GROUP@', '@DESCR@')//
