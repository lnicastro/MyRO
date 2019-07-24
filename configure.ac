# ----------------------------------------------------------------------^
# Copyright (C) 2005, 2006, 2007 Giorgio Calderone <gcalderone@ifc.inaf.it>
# 
# This file is part of MYRO.
# 
#     MYRO is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     (at your option) any later version.
# 
#     MYRO is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with MYRO; if not, write to the Free Software
#     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# 
# ----------------------------------------------------------------------$
AC_INIT([myro],
        [0.3.2-alpha5],
        [Giorgio Calderone <giorgio.calderone@inaf.it>, Luciano Nicastro <luciano.nicastro@inaf.it>],
        [myro])

AC_CONFIG_AUX_DIR(config)
AM_CONFIG_HEADER(src/config.h)
AM_INIT_AUTOMAKE([dist-bzip2])

AC_LANG(C++)
AC_DEFINE([CXX_HAS_BUGGY_FOR_LOOPS], [], [Description])
AC_DEFINE([CXX_HAS_NO_BOOL], [], [Description])
AC_DEFINE([NDEBUG], [], [Description])
AC_DEFINE([YOUR_OS], [], [Description])

AC_PROG_LIBTOOL

AC_PATH_PROG([PERL], [perl])
if [[ -z "$PERL" ]]; then AC_MSG_ERROR([Could not find program: perl]); fi

AC_PATH_PROG([MYSQL], [mysql])
if [[ -z "$MYSQL" ]]; then AC_MSG_ERROR([Could not find program: mysql]); fi

AC_PATH_PROG([MYSQL_CONFIG], [mysql_config])
if [[ -z "$MYSQL_CONFIG" ]]; then AC_MSG_ERROR([Could not find program: mysql_config]); fi

DUMMY0=`$MYSQL_CONFIG --cflags`
CPPFLAGS="-Wall $CPPFLAGS $DUMMY0"
AC_CHECK_HEADERS([mysql.h], [], [AC_MSG_ERROR([Couldn't find file mysql.h])])


MYRO_VERSION="$PACKAGE_VERSION"

# LN 09/06/2011: manage shared lib extension
eval SHARED_EXT=\"$shrext_cmds\"
AC_SUBST(SHARED_EXT)

AC_CONFIG_FILES([
   Makefile
   version
   doc/Makefile
   src/Makefile
   sql/Makefile
   scripts/Makefile
   scripts/myro
])

AC_OUTPUT
