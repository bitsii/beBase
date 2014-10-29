The build4's are for generating on one platform for another platform and then building on another (not quite cross compiling, cross generating).  This is to bootstrap from one platform to another.  It's best to force recompilation every time, there is at least include\(platform)\*.o, the command below should give you a build, artifacts will be under deploy4

make -Bf target4\Base\target\Base\Gen\BEX_Base.make
