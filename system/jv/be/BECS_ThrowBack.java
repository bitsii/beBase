// Copyright 2015 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

package be;

import be.BEC_2_6_6_SystemObject;
import be.BEC_2_6_9_SystemException;
import be.BEC_2_4_6_TextString;
import be.BEC_2_4_3_MathInt;

public class BECS_ThrowBack extends RuntimeException {
    
    public static BEC_2_6_6_SystemObject handleThrow(Throwable theThrow) throws Throwable {
        //will return a systemobject/except type
        //the call will get the stack trace, if thethings is of the right type (throwback
        //with a thrown which is an except) that will be populated, otherwise, an appropro
        //except will be created, will defined types for those, a fallback for others
        //?native except? not the base class, something to distinguish
        //instance of throwable
        
        //create list of frames, each with lang type (org native, then be after
        //trans) classname file line
        //trans happens in common be code
        if (theThrow != null) {
            
            //comment these when all done wrapping/handling cases
            //System.err.println(theThrow.getMessage());
            //theThrow.printStackTrace();
            BEC_2_6_6_SystemObject thrown;
            if (theThrow instanceof BECS_ThrowBack) {
              thrown = ((BECS_ThrowBack)theThrow).thrown;
            } else {
              BEC_2_6_9_SystemException throwne = new BEC_2_6_9_SystemException();
              if (theThrow.getMessage() == null) {
                throwne.bem_new_0();
              } else {
                throwne.bem_new_1(new BEC_2_4_6_TextString(theThrow.getMessage()));
              }
              thrown = throwne;
            }
            if (thrown instanceof BEC_2_6_9_SystemException) {
                BEC_2_6_9_SystemException bes = (BEC_2_6_9_SystemException)thrown;
                try {
                  //setup stack trace
                  BEC_2_4_6_TextString lang = new BEC_2_4_6_TextString("jv");
                  bes.bem_langSet_1(lang);
                  StackTraceElement[] jframes = theThrow.getStackTrace();
                  for (int i = 0;i < jframes.length;i++) {
                      StackTraceElement jf = jframes[i];
                      bes.bem_addFrame_4(new BEC_2_4_6_TextString(jf.getClassName()),
                                          new BEC_2_4_6_TextString(jf.getMethodName()),
                                          new BEC_2_4_6_TextString(jf.getFileName()),
                                          new BEC_2_4_3_MathInt(jf.getLineNumber()));
                  }
                } catch (Exception sfe) { }
                return bes;
            } else {
                //you can throw whatever...
                return ((BECS_ThrowBack)theThrow).thrown;
            }
        } else {
            //System.err.println("handleThrow received null");
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

