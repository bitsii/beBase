// Copyright 2015 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

namespace be.BELS_Base {

using System;
using System.Diagnostics;
using be;

public class BECS_ThrowBack : Exception {
    
    public static BEC_2_6_6_SystemObject handleThrow(Exception theThrowArg) {
        //will return a systemobject/except type
        //the call will get the stack trace, if thethings is of the right type (throwback
        //with a thrown which is an except) that will be populated, otherwise, an appropro
        //except will be created, will defined types for those, a fallback for others
        //?native except? not the base class, something to distinguish
        //instance of throwable
        
        //create list of frames, each with lang type (org native, then be after
        //trans) classname file line
        //trans happens in common be code
        if (theThrowArg != null) {
            
            //comment these when all done wrapping/handling cases
            //Console.Error.WriteLine(theThrowArg.Message);
            //Console.Error.WriteLine(theThrowArg.StackTrace);
            
            BEC_2_6_9_SystemException bes;
            var theThrow = theThrowArg as BECS_ThrowBack;
            if (theThrow != null) {
              bes = theThrow.thrown as BEC_2_6_9_SystemException;
            } else {
              bes = new BEC_2_6_9_SystemException();
              bes.bem_new_1(new BEC_2_4_6_TextString(theThrowArg.Message));
            }
            if (bes != null) {
                //setup stack trace
                BEC_2_4_6_TextString lang = new BEC_2_4_6_TextString("cs");
                bes.bem_langSet_1(lang);
                bes.bem_framesTextSet_1(new BEC_2_4_6_TextString(theThrowArg.StackTrace));
                return bes;
            } else {
                //you can throw whatever...
                return theThrow.thrown;
            }
        } else {
            //Console.Error.WriteLine("handleThrow received null");
            //TODO put in appropo exception
        }
        return null;
    }
    
    public BEC_2_6_6_SystemObject thrown;
    
    public BECS_ThrowBack() { }
    
    public BECS_ThrowBack(BEC_2_6_6_SystemObject thrown) {
        this.thrown = thrown;
    }
    
}

}

