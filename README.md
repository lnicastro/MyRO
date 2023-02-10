# MyRO
`My Record Oriented privilege system` is a technique we use in MySQL to implement a per-record database tables privilege system.
All database servers implement a privilege system based on tables or columns, that is if a user has grants to access a certain table (or a table's column) he can access all records of that table (or that table's column).
MyRO lets you specify grants on a record level so a user can access only those records it is allowed to. A consequence of this is that different users reading the same table will see different records.
The grant mechanism provided by MyRO is similar to that of a Unix file system, that is each record belongs to a `owner` and a `group` and has three sets of permissions associated (for the owner, the users belonging to the group and all other users) that specify whether that record can be read and/or written.


[![DOI](https://zenodo.org/badge/190257572.svg)](https://zenodo.org/badge/latestdoi/190257572)


See the [documentation](doc/myro.pdf).

MyRO has been developed on the GNU/Linux platform and is released under the GPL license.

## Requirements

1. MySQL and its development file (`mysql.h`, `mysql_config`)
2. make or gmake
3. Perl `DBI/DBD-MySQL` modules

## Compile and install
Assuming you download MyRO via `git`:
```
git clone https://github.com/lnicastro/MyRO.git
cd MyRO

touch configure aclocal.m4 Makefile.in src/config.h.in

./configure
make
sudo make install
```

## Installing MyRO facilities in MySQL
`myro` is a Perl script used to perform various DB-related tasks.
It uses the Perl `DBI/DBD-MySQL` modules to communicate with the MySQL server.
First of all be sure you have these modules installed. You can install them using `cpan DBD::mysql` or the OS specific command.

On Mac OS using MacPorts:
```
sudo port install p5-dbd-mysql
```
On Debian, Ubuntu and variants:
```
sudo apt-get install libdbd-mysql-perl
```
On Red Hat, Fedora, centOS, and variants:
```
sudo yum install "perl(DBD::mysql)"
```
On openSUSE
```
sudo zypper install perl-DBD-mysql
```

Once the Perl modules are installed, to actually enable the MyRO facilities, you need to run the installation command:
```
myro --install
```

You'll be asked the MySQL root password to complete this task.
See the [documentation](doc/myro.pdf) for a full description or run:
```
myro --help
```
