package abe.BELS_Base;

import abe.BEL_4_Base.BEC_6_6_SystemObject;
import abe.BEL_4_Base.BEC_6_9_SystemException;
import abe.BEL_4_Base.BEC_4_6_TextString;
import abe.BEL_4_Base.BEC_4_3_MathInt;

public class BECS_ThrowBack extends RuntimeException {
    
    public static BEC_6_6_SystemObject handleThrow(Throwable theThrow) throws Throwable {
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
            System.err.println(theThrow.getMessage());
            theThrow.printStackTrace();
            
            if (theThrow instanceof BECS_ThrowBack) {
                if (((BECS_ThrowBack)theThrow).thrown instanceof BEC_6_9_SystemException) {
                    BEC_6_9_SystemException bes = (BEC_6_9_SystemException)((BECS_ThrowBack)theThrow).thrown;
                    //setup stack trace
                    BEC_4_6_TextString lang = new BEC_4_6_TextString("jv");
                    bes.bem_langSet_1(lang);
                    StackTraceElement[] jframes = theThrow.getStackTrace();
                    for (int i = 0;i < jframes.length;i++) {
                        StackTraceElement jf = jframes[i];
                        bes.bem_addFrame_4(new BEC_4_6_TextString(jf.getClassName()),
                                            new BEC_4_6_TextString(jf.getMethodName()),
                                            new BEC_4_6_TextString(jf.getFileName()),
                                            new BEC_4_3_MathInt(jf.getLineNumber()));
                    }
                    return bes;
                } else {
                    //you can throw whatever...
                    return ((BECS_ThrowBack)theThrow).thrown;
                }
            } else {
                System.err.println("handleThrow received non-be exception");
                //TODO wrap in an appropo exception, map well knowns,
                //have a general for others
                return null;
            }
        } else {
            System.err.println("handleThrow received null");
            //TODO put in appropo exception
        }
        return null;
    }
    
    public BEC_6_6_SystemObject thrown;
    
    public BECS_ThrowBack() { }
    
    public BECS_ThrowBack(BEC_6_6_SystemObject thrown) {
        this.thrown = thrown;
    }
    
}

