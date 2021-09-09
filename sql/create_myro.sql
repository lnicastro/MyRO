#@ONERR_DIE|Cannot create database myro|
CREATE DATABASE myro//
USE myro//


#@ONERR_DIE|Cannot create table myro|
CREATE TABLE myro (name CHAR(50),
                   value CHAR(50), 
                   UNIQUE KEY(name))//

#@ONERR_DIE|Cannot insert into table myro|
INSERT INTO myro VALUES ('VERSION', '@MYROVER@')//


#@ONERR_IGNORE||
DROP TABLE IF EXISTS tbl//

#@ONERR_DIE|Cannot create table tbl|
CREATE TABLE tbl(db CHAR(50),
                 name CHAR(50),
                 viewname CHAR(50),
                 flag BOOL NOT NULL DEFAULT 1,
                 PRIMARY KEY(db, name))//

#@ONERR_IGNORE||
DROP TABLE IF EXISTS usr//

#@ONERR_DIE|Cannot create table usr|
CREATE TABLE usr(uid      TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
                 usr      CHAR(50) NOT NULL,
                 su       BOOL NOT NULL DEFAULT 0,
                 defgid   TINYINT UNSIGNED NOT NULL DEFAULT 1,
                 defperm  TINYINT UNSIGNED NOT NULL DEFAULT 11,
                 descr    VARCHAR(200),
                 email    VARCHAR(200),
                 flag     BOOL NOT NULL DEFAULT 1,
                 PRIMARY KEY(uid),
                 UNIQUE KEY(usr))//

#@ONERR_IGNORE||
DROP TABLE IF EXISTS grp//

#@ONERR_DIE|Cannot create table grp|
CREATE TABLE grp(gid    TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
                 grp    CHAR(50) NOT NULL,
                 descr  VARCHAR(200),
                 PRIMARY KEY(gid),
                 UNIQUE KEY(grp))//

#@ONERR_DIE|Cannot insert into table grp|
INSERT INTO grp(grp, descr) VALUES('anygroup', 'Each user belonging to this group automatically belongs to all other groups')//

#@ONERR_IGNORE||
DROP TABLE IF EXISTS usrgrp//

#@ONERR_DIE|Cannot create table usrgrp|
CREATE TABLE usrgrp(uid  TINYINT UNSIGNED NOT NULL,
                    gid  TINYINT UNSIGNED NOT NULL,
                    UNIQUE KEY(uid, gid),
                    INDEX(gid))//


CREATE TABLE mcsgrant(uid      TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
                      appname  CHAR(30) NOT NULL,
                      cmd      CHAR(30) NOT NULL,
                      perm     TINYINT UNSIGNED NOT NULL DEFAULT 1,
                      PRIMARY KEY(uid, appname, cmd))//
