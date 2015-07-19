// Copyright 2015 Craig Welch
//
// Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
// http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
// <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
// option. This file may not be copied, modified, or distributed
// except according to those terms.

var be_BELS_Base_BECS_Runtime = function() { }

var be_BELS_Base_BECS_ThrowBack = function(thrown, error) { 
        this.thrown = thrown;
        this.error = error;
}

var be_BELS_Base_BECS_ThrowBack_handleThrow = function(theThrow) {
    if (null != theThrow) {
        if (theThrow instanceof be_BELS_Base_BECS_ThrowBack) {
          if (null != theThrow.error &&
            null != theThrow.error.stack) {
            console.log(theThrow.error.stack);
          }
          if (null != theThrow.thrown &&
              theThrow.thrown instanceof be_BEL_4_Base_BEC_6_9_SystemException) {
              var bes = theThrow.thrown;
              bes.bem_langSet_1(
                 new be_BEL_4_Base_BEC_4_6_TextString().beml_set_bevi_bytes(bes.bems_stringToBytes_1("js"))
                 );
              bes.bem_framesTextSet_1(new be_BEL_4_Base_BEC_4_6_TextString().beml_set_bevi_bytes(bes.bems_stringToBytes_1(theThrow.error.stack)));
              return bes;
          } else {
            return theThrow.thrown;
          }
        } else {
          console.log(theThrow);
          console.log(theThrow.stack);
        }
    } else {
        console.log("handleThrow received null");
    }
    return null;
}

be_BELS_Base_BECS_Runtime.prototype.hashCounter = 0;//for object derived hashcodes

be_BELS_Base_BECS_Runtime.prototype.typeInstances = function() { }

be_BELS_Base_BECS_Runtime.prototype.minArg = 2;

//be_BELS_Base_BECS_Runtime.prototype.typeInstances["tb"] = new be_BELS_Base_BECS_ThrowBack();

