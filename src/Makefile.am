# ----------------------------------------------------------------------^
# Copyright (C) 2004, 2005, 2006, 2007 Giorgio Calderone <gcalderone@ifc.inaf.it>
# 
# This file is part of MYRO.
# 
# MYRO is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# MYRO is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with MYRO; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# 
# ----------------------------------------------------------------------$

noinst_HEADERS = udf_utils.hh

lib_LTLIBRARIES = libmyro.la
libmyro_la_SOURCES = libmyro.cc


install-data-hook:
# LN 09/06/2011: manage shared lib extension
# Since version 5.1.24 the option --plugindir was added
#	if test -z $$pd; then pd="`@MYSQL_CONFIG@ --libs | @PERL@ ../selectflags.pl | @PERL@ -pe 's/-L//g'`"; fi;
	@if test -e /etc/my.cnf; then pd="`cat /etc/my.cnf | grep '^plugin_dir' | @AWK@ -F '=' '{print $$2}'`"; \
	else echo WARNING: no /etc/my.cnf file found. && pd=""; fi; \
	if test -z $$pd; then pd="`@MYSQL_CONFIG@ --plugindir`"; fi; \
	echo "MySQL plugin dir: $$pd"; \
	if test $$pd != ${libdir}; \
	then echo "Creating a symbolic link in $$pd to ${libdir}/libmyro@SHARED_EXT@"; \
	ln -sf ${libdir}/libmyro@SHARED_EXT@ $$pd/libmyro.so; fi
