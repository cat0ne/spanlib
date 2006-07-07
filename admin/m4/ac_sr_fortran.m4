################################################################################
# F90 compiler
################################################################################
AC_DEFUN([AC_SR_FORTRAN],
[
## OPTIMIZATION LEVELS
##
AC_ARG_ENABLE(
    optimization,
    [  --enable-optimization=level - Control optimization level.
                             The following levels are supported.
       debug     - debugging compiler options will be selected.
       normal    - soft optimization (default).
       aggressive - aggressive optimization (YOU HAVE TO VERIFY YOUR RESULTS!).],
    ,
    enable_optimization=normal
             )
#
## PROFILING (if it is available)
##
AC_ARG_ENABLE(
    profiling,
    [  --enable-profiling - Turn on profiling compiler options.],
    enable_prof=yes,
    enable_prof=no
             )
# Main program
AC_LANG(Fortran)
AC_PROG_FC(ifort fort xlf90 pgf90 epcf90 pathf90 ifc efc f90 xlf95 lf95 g95 f95 sxf90)
if test ! -n "$FC" ; then
	AC_SR_ERROR([No Fortran 90 compiler available on this machine.
               Please use FC to specify it or
               update your environnement variable PATH or
               install a Fortran 90 compiler.])
fi

# LD FLAGS
  case "$FC" in
##    GENERIC FORTRAN COMPILER (SGI-IRIX, HP-TRUE64, NEC-SX )
      f90)
        case "$host" in
        *-sgi-irix*)
          case "$enable_optimization" in
	    debug)
              AC_MSG_NOTICE([**** DEBUGGING OPTIONS are SELECTED *****])
              FCFLAGS="-g -O0 -C -fullwarn -DEBUG:trap_uninitialized=ON:subscript_check=ON"
              LDFLAGS="-g"
            ;;
            aggressive)
              AC_MSG_NOTICE([**** AGGRESSIVE COMPILER OPTIONS are SELECTED *****])
    	      FCFLAGS="-g3 -O3 -ipa -listing"
              LDFLAGS="-g3"
            ;;
            normal|*)
              AC_MSG_NOTICE([**** NORMAL MODE *****])
	      FCFLAGS="-g3 -O2 -listing"
              LDFLAGS="-g3"
	    ;;
          esac
	  if test "$enable_prof" = "yes" ; then
            AC_SR_WARNING([!!! NO PROFILING COMPILER OPTIONS ON IRIX SYSTEM !!!])
            AC_SR_WARNING([!!!        PLEASE READ SPEEDSHOP MANUAL          !!!])
          fi
        ;;
        alpha*-dec-osf*)
          case "$enable_optimization" in
	    debug)
              AC_MSG_NOTICE([**** DEBUGGING OPTIONS are SELECTED *****])
              FCFLAGS="-V -ladebug -g -O0 -C -check overflow -check underflow -warn nouninitialized -warn argument_checking"
              LDFLAGS="-ladebug -g"
            ;;
            aggressive)
              AC_MSG_NOTICE([**** AGGRESSIVE COMPILER OPTIONS are SELECTED *****])
    	      FCFLAGS="-V -g3 -fast -math_library fast"
              LDFLAGS="-g3 -fast -math_library fast"
            ;;
            normal|*)
              AC_MSG_NOTICE([**** NORMAL MODE *****])
	      FCFLAGS="-V -g3 -O"
              LDFLAGS=""
	    ;;
          esac
	  if test "$enable_prof" = "yes" ; then
            AC_MSG_NOTICE([**** PROFILING is SELECTED (gprof) *****])
            FCFLAGS="-pg $FCFLAGS"
            LDFLAGS="-pg $LDFLAGS"
          fi
        ;;
        *nec*superux*)
          case "$enable_optimization" in
	    debug)
              AC_MSG_NOTICE([**** DEBUGGING OPTIONS are SELECTED *****])
              FCFLAGS='-C debug -eR -eP -R1 -R5 -Wf"-L nostdout" -Wf"-L source mrgmsg" -Wf"-L summary" -Wf"-init stack=nan" -Wf"-init heap=nan" -Wl"-f nan" Wf"-msg d" -Wf"-msg o"'
              LDFLAGS="-C debug"
            ;;
            aggressive)
              AC_MSG_NOTICE([**** AGGRESSIVE COMPILER OPTIONS are SELECTED *****])
    	      FCFLAGS='-C hopt -R1 -R5 -Wf"-L nostdout"  -Wf"-L summary" -Wf"-pvctl fullmsg" -Wf"-O infomsg"'
              LDFLAGS="-C hopt"
            ;;
            normal|*)
              AC_MSG_NOTICE([**** NORMAL MODE *****])
	      FCFLAGS='-R1 -R5 -Wf"-L nostdout"  -Wf"-L summary" -Wf"-pvctl fullmsg" -Wf"-O infomsg"'
              LDFLAGS=""
	    ;;
          esac
	  if test "$enable_prof" = "yes" ; then
            AC_MSG_NOTICE([**** PROFILING is SELECTED (gprof) *****])
            FCFLAGS="-ftrace $FCFLAGS"
            LDFLAGS="-ftrace $LDFLAGS"
          fi
        ;;
        *)
          AC_MSG_WARN([!!! HOST and/or SYSTEM is UNKNOWN : $host !!!])
          exit
        ;;
        esac
        ;;
##    INTEL FORTRAN COMPILER on LINUX OPERATING SYSTEM
      ifort|efc|ifc)
	case "$enable_optimization" in
	  debug)
            AC_MSG_NOTICE([**** DEBUGGING OPTIONS are SELECTED *****])
            FCFLAGS="-g -O0 -no_cpprt -check all -traceback -auto -warn all -warn unused -debug variable_locations -inline_debug_info"
	    LDFLAGS="-g -O0 -no_cpprt -check all -traceback -auto -inline_debug_info"
## if idb bugs use          FCFLAGS="-g -O0 "
## if idb bugs use 	    LDFLAGS="-g -O0 "
          ;;
          aggressive)
            AC_MSG_NOTICE([**** AGGRESSIVE COMPILER OPTIONS are SELECTED *****])
    	    FCFLAGS="-fast"
            LDFLAGS="-fast"
          ;;
          normal|*)
            AC_MSG_NOTICE([**** NORMAL MODE *****])
	    FCFLAGS="-g -O3 -132 -check bounds"
	  ;;
	esac
	if test "$enable_prof" = "yes" ; then
          AC_MSG_NOTICE([**** PROFILING is SELECTED (gprof) *****])
          FCFLAGS="-pg $FCFLAGS"
          LDFLAGS="-pg $LDFLAGS"
        fi
        ;;
##    IBM FORTRAN COMPILER on AIX OPERATING SYSTEM
      xlf90|xlf95)
	case "$enable_optimization" in
	  debug)
            FCFLAGS="-qsuffix=f=f90 -qfree=f90 -g -qnooptimize -C -qinitauto=7FBFFFFF -qflttrap=overflow:underflow:zerodivide:invalid:enable -qfloat=nans -qsigtrap -qextchk"
          ;;
          aggressive)
            FCFLAGS="-qsuffix=f=f90 -qfree=f90 -O3 -qstrict"
          ;;
          normal|*)
            FCFLAGS="-qsuffix=f=f90 -qfree=f90 -O5 -qipa=level=2 -qessl -qhot=vector -qunroll"
            LDFLAGS="-qessl"
	  ;;
	esac
	if test "$enable_prof" = "yes" ; then
          AC_MSG_NOTICE([**** PROFILING is SELECTED (gprof) *****])
          FCFLAGS="-pg $FCFLAGS"
          LDFLAGS="-pg $LDFLAGS"
        fi
        ;;
##    PORTLAND GROUP FORTRAN COMPILER
      pgf90)
	FCFLAGS="-g"
        ;;
##    GENERIC Fortran 95 compiler (not tested)
      f95)
	FCFLAGS="-g"
        ;;
##    HP_COMPAQ ALPHASERVER FORTRAN COMPILER (LINUX OPERATING SYSTEM)
      fort)
	FCFLAGS="-g"
        ;;
##    Lahey-Fujitsu compiler
      lf95)
	FCFLAGS="-g"
        ;;
##    PATHSCALE FORTRAN COMPILER (AMD-OPTERON) (Not Tested)
      pathf90)
	FCFLAGS="-g"
        ;;
##    GNU FORTRAN 90/95 COMPILER (Tested on Intel-PC and Mac OS X)
      g95)
	case "$enable_optimization" in
	  debug)
            AC_MSG_NOTICE([**** DEBUGGING OPTIONS are SELECTED *****])
            FCFLAGS="-g -O0 -fno-second-underscore -Wall -Wunset-vars -Wunused-vars -fbounds-check "
	    LDFLAGS="-g -O0-fno-second-underscore"
          ;;
          aggressive)
            AC_MSG_NOTICE([**** AGGRESSIVE COMPILER OPTIONS are SELECTED *****])
    	    FCFLAGS="-g -O3 -fno-second-underscore"
            LDFLAGS="-g -O3 -fno-second-underscore"
          ;;
          normal|*)
            AC_MSG_NOTICE([**** NORMAL MODE *****])
	    FCFLAGS="-g -O -fno-second-underscore"
            LDFLAGS="-g -O -fno-second-underscore"
	  ;;
	esac
	if test "$enable_prof" = "yes" ; then
          AC_MSG_NOTICE([**** PROFILING is SELECTED (gprof) *****])
          FCFLAGS="-pg $FCFLAGS"
          LDFLAGS="-pg $LDFLAGS"
        fi
        ;;
  esac
	AC_FC_SRCEXT(f90)
	AC_FC_FREEFORM()
])