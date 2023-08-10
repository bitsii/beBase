/*
 * Copyright (c) 2006-2023, the Bennt Authors.
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *
 * Licensed under the BSD 2-Clause License (the "License").
 * See the LICENSE file in the project root for more information.
 *
 */

use System:Command;
use IO:File:Path;
use IO:File;

use final class Build:Cycle:Main {
   
   main() {
        ("Beginning build test cycle").print();
        Time:Interval cycleStart = Time:Interval.now();
        
        //Build 3 times to be sure any change impacts are found
        //first build is base (b/c it may or may not, itself, be from a changed version), it will have the changes in it but it
        //was not necessarily generated with the changes (this is the build which ran this code...)
        //second build has the changes and was built by a build with the changes, was generated with the changed code
        //third build is a test build - built by something with the changes which had the consequence of the changes
        //then the test suite is built and run from the final build
        
        Int result;
        Path buildCmd;
        
        //Call build with the args in-process
        List args = List.new(1);
        args[0] = "-buildFile=build/cycle1.txt";
        result = Build:Build.new().main(args);
        ("cycle1 build result " + result).print();
        
        if (result != 0) {
            throw(System:Exception.new("Cycle failed with non-zero result at step 1 " + result));
        }
        ("Cycle step 1 complete").print();
        
        buildCmd = Path.apNew("./cycle/deploy1/Build.exe");
        result = System:Command.new().run(buildCmd.toString() + " -buildFile=build/cycle2.txt");
        
        if (result != 0) {
            throw(System:Exception.new("Cycle failed with non-zero result at step 2 " + result));
        }
        ("Cycle step 2 complete").print();
        
        buildCmd = Path.apNew("./cycle/deploy2/Build.exe");
        result = System:Command.new().run(buildCmd.toString() + " -deployPath=cycle/deployExtended -buildPath=cycle/targetExtended -buildFile=build/extended.txt");
        
        if (result != 0) {
            throw(System:Exception.new("Cycle failed with non-zero result at step 3 " + result));
        }
        
        result = System:Command.new().run(buildCmd.toString() + " -buildFile=build/cycleExtendedTestFar.txt -run");
        
        if (result != 0) {
            throw(System:Exception.new("Cycle failed with non-zero result at step 3 " + result));
        }
        ("Cycle step 3 complete").print();
        
        Time:Interval cycleTime = Time:Interval.now() - cycleStart;
        ("TIME: Cycle completed in " + cycleTime.toStringMinutes()).print();
      
        ("Build test cycle done").print();
   }
   
}
