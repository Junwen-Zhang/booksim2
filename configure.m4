dnl -*- Autoconf -*-

AC_DEFUN([SST_booksim2_CONFIG], [
  sst_check_booksim2_happy="yes"

  AC_ARG_WITH([booksim2],
    [AS_HELP_STRING([--with-booksim2@<:@=DIR@:>@],
      [Use BookSim2 network simulator installed in optionally specified DIR])])

  AS_IF([test "$with_booksim2" = "no"], [sst_check_booksim2_happy="no"])

  CXXFLAGS_saved="$CXXFLAGS"
  LDFLAGS_saved="$LDFLAGS"

  AS_IF([test "$sst_check_booksim2_happy" = "yes"], [
    AS_IF([test ! -z "$with_booksim2" -a "$with_booksim2" != "yes"],
      [BOOKSIM2_CPPFLAGS="-I$with_booksim2"
       CXXFLAGS="$BOOKSIM2_CPPFLAGS $CXXFLAGS"
       BOOKSIM2_LDFLAGS="-L$with_booksim2"
       LDFLAGS="$BOOKSIM2_LDFLAGS $LDFLAGS"],
      [BOOKSIM2_CPPFLAGS=
       BOOKSIM2_LDFLAGS=])

    AC_LANG_PUSH([C++])
    AC_CHECK_HEADERS([booksim2.h], [], [sst_check_booksim2_happy="no"])
    AC_LANG_POP([C++])
  ])

  AS_IF([test "$sst_check_booksim2_happy" = "yes"], [
    AC_MSG_CHECKING([for BookSim2 library])
    AC_MSG_RESULT([yes])
  ], [
    AC_MSG_CHECKING([for BookSim2 library])
    AC_MSG_RESULT([no])
  ])

  CXXFLAGS="$CXXFLAGS_saved"
  LDFLAGS="$LDFLAGS_saved"

  AC_SUBST([BOOKSIM2_CPPFLAGS])
  AC_SUBST([BOOKSIM2_LDFLAGS])
  AM_CONDITIONAL([USE_BOOKSIM2], [test "$sst_check_booksim2_happy" = "yes"])
  AS_IF([test "$sst_check_booksim2_happy" = "yes"], 
        [AC_DEFINE([HAVE_BOOKSIM2], [1], [Set to 1 if BookSim2 is found])])
  AC_DEFINE_UNQUOTED([BOOKSIM2_CPPFLAGS], ["$BOOKSIM2_CPPFLAGS"], [BookSim2 preprocessing flags])
  AC_DEFINE_UNQUOTED([BOOKSIM2_LDFLAGS], ["$BOOKSIM2_LDFLAGS"], [BookSim2 linking flags])

  AS_IF([test "$sst_check_booksim2_happy" = "yes"], [$1], [$2])
])
