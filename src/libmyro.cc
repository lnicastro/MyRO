// ----------------------------------------------------------------------^
// Copyright (C) 2004, 2005, 2006, 2007 Giorgio Calderone <gcalderone@ifc.inaf.it>
// 
// This file is part of MYRO.
// 
// MYRO is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// 
// MYRO is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with MYRO; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
// 
// ----------------------------------------------------------------------$

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <pthread.h>
#include <vector>

//#include <my_global.h>
//#include <my_sys.h>

#include <mysql.h>

#if MYSQL_VERSION_ID >= 80000  &&  MYSQL_VERSION_ID < 100000
typedef bool   my_bool;
#endif
typedef long long   longlong;
typedef unsigned long long      uint64;

#if MYSQL_VERSION_ID >= 80000

#include <sys/types.h>

#else

// version 5.5.x doesn't contain mysql_priv.h . We need to add the provided includes.
#if MYSQL_VERSION_ID >= 50505

#include "my_global.h"                   /* ulonglong */

#if MYSQL_VERSION_ID < 50700  // 5.6

#include "sql_priv.h"
#include "sql_class.h"           // MYSQL_HANDLERTON_INTERFACE_VERSION
#include "probes_mysql.h"

#else

// These two are not present in 5.7.9
#if MYSQL_VERSION_ID < 50709
#include <my_pthread.h>
#include <sql_priv.h>
#endif

#endif  // < 50700

#endif  // >= 50505

#endif  // >= 80000

#include "udf_utils.hh"


struct TablePerm
{
  int uid;
  int su;
  bool memb_of_anygr;
  std::vector<int> gid;
};


//NOTE: this class should be the same as MCS's one
template<class BASE>
class ThreadSpecificData 
{
private:
  pthread_key_t key;
  int ltag;

  static void generic_destructor(void* p)
  { delete ((BASE*) p); }

  void (*destructor)(void*);

public:
  ThreadSpecificData(void (*ext_destructor)(void*) = NULL)
  {
    destructor = generic_destructor;
    if (ext_destructor)
      destructor = ext_destructor;
      
    pthread_key_create(&key, destructor); 
  }

  ~ThreadSpecificData()
  { pthread_key_delete(key); }

  void clear()
  { 
    void* p = getp();
    if (p)
      (destructor)(p);

    pthread_setspecific(key, NULL);
  }

  void init(BASE* p = NULL, int tag = 0)
  {
    clear();

    if (! p)
      p = new BASE();

    pthread_setspecific(key, p);
    ltag = tag;
  }

  int tag() 
  { return ltag; }

  BASE* operator->() const
  { return  ((BASE*) pthread_getspecific(key)); }

  BASE* getp()
  { return  ((BASE*) pthread_getspecific(key)); }
};

static ThreadSpecificData<struct TablePerm> identity;


extern "C" {
  DEFINE_FUNCTION(longlong, myro_error);
  DEFINE_FUNCTION(longlong, myro_Count);
  DEFINE_FUNCTION(longlong, myro_userValue);
  DEFINE_FUNCTION(longlong, myro_setIdentity);
  DEFINE_FUNCTION(longlong, myro_setGid);
  DEFINE_FUNCTION(longlong, myro_granted);
}



//--------------------------------------------------------------------


my_bool myro_error_init(UDF_INIT *init, UDF_ARGS *args, char *message)
{
    strcpy(message, "myro_error has been called.");

    if (args->arg_count > 0)
	if (args->arg_type[0] == STRING_RESULT)
	    if (args->args[0])
		strncpy(message, args->args[0], 80);

    return 1;
}

longlong myro_error(UDF_INIT *init, UDF_ARGS *args, char *is_null,
		 char *error)
{
    return 0;
}

void myro_error_deinit(UDF_INIT *init)
{}


//--------------------------------------------------------------------


my_bool myro_Count_init(UDF_INIT *init, UDF_ARGS *args, char *message)
{
  const char* argerr = "myro_Count()";

  if (args->arg_count != 0) {
    strcpy(message, argerr);
    return 1;
  }

  ALLOC_MYDATA;
  data->val = -1;
  return 0;
}

longlong myro_Count(UDF_INIT *init, UDF_ARGS *args, char *is_null,
			char *error)
{
    MYDATA;
    CLEAR;
    data->val++;
    RETURN_MYDATA;
}


void myro_Count_deinit(UDF_INIT *init)
{
  FREE_MYDATA;
}

//--------------------------------------------------------------------



my_bool myro_userValue_init(UDF_INIT *init, UDF_ARGS *args, char *message)
{
  const char* argerr = "myro_userValue(val INT)";

  CHECK_ARG_NUM(1);
  CHECK_ARG_NOT_TYPE(0, STRING_RESULT);

  ALLOC_MYDATA;
  return 0;
}

longlong myro_userValue(UDF_INIT *init, UDF_ARGS *args, char *is_null,
			char *error)
{
    MYDATA;
    CLEAR;

    if (data->firstTime) { //Store the value
      if (ISNULL(0))
	data->is_null = 1;
      else {
	data->is_null = 0;
	data->val = IARGS(0);
      }
    }

    RETURN_MYDATA;
}


void myro_userValue_deinit(UDF_INIT *init)
{
  FREE_MYDATA;
}


//--------------------------------------------------------------------


my_bool myro_setIdentity_init(UDF_INIT *init, UDF_ARGS *args, char *message)
{
  const char* argerr = "myro_setIdentity(uid INT, su INT, member_anygroup INT)";

  CHECK_ARG_NUM(3);
  CHECK_ARG_NOT_TYPE(0, STRING_RESULT);
  CHECK_ARG_NOT_TYPE(1, STRING_RESULT);
  CHECK_ARG_NOT_TYPE(2, STRING_RESULT);

  identity.init();

  return 0;
}

longlong myro_setIdentity(UDF_INIT *init, UDF_ARGS *args, char *is_null,
			char *error)
{
  identity->uid = IARGS(0);
  identity->su  = IARGS(1);
  identity->memb_of_anygr = IARGS(2);
  return 1;
}

void myro_setIdentity_deinit(UDF_INIT *init)
{}

//--------------------------------------------------------------------



my_bool myro_setGid_init(UDF_INIT *init, UDF_ARGS *args, char *message)
{
  const char* argerr = "myro_setGid(gid INT)";

  CHECK_ARG_NUM(1);
  CHECK_ARG_NOT_TYPE(0, STRING_RESULT);

  return 0;
}

longlong myro_setGid(UDF_INIT *init, UDF_ARGS *args, char *is_null,
			char *error)
{
  int gid = IARGS(0);

  if (gid == -1)
    identity->gid.clear();
  else
    identity->gid.push_back(gid);

  return 1;
}

void myro_setGid_deinit(UDF_INIT *init)
{}


//--------------------------------------------------------------------

my_bool myro_granted_init(UDF_INIT *init, UDF_ARGS *args, char *message)
{
  const char* argerr = "myro_granted(my_uid INT, my_gid INT, my_perm INT)";

  CHECK_ARG_NUM(3);
  CHECK_ARG_TYPE(0, INT_RESULT);
  CHECK_ARG_TYPE(1, INT_RESULT);
  CHECK_ARG_TYPE(2, INT_RESULT);

  return 0;
}

longlong myro_granted(UDF_INIT *init, UDF_ARGS *args, char *is_null,
			char *error)
{
  int my_uid  = IARGS(0);
  int my_gid  = IARGS(1);
  int my_perm = IARGS(2);

  if (
      (identity->su)                                       ||
      ((my_perm &  2)    &&    (my_uid == identity->uid))  ||
      (my_perm >= 32)                                      ||
      ((my_perm &  8)    &&    identity->memb_of_anygr)
      )
    return 1;

  if (my_perm & 8) {
    for (unsigned int i=0; i<identity->gid.size(); i++)
      if (identity->gid[i] == my_gid)
	return 1;
  }

  return 0;
}

void myro_granted_deinit(UDF_INIT *init)
{}


//--------------------------------------------------------------------
