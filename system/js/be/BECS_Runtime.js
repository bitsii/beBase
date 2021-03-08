// Copyright 2015 The Abelii Authors. All rights reserved.
// Use of this source code is governed by the BSD-3-Clause
// license that can be found in the LICENSE file.

var be_BECS_Runtime = function() { }

var be_BECS_ThrowBack = function(thrown, error) { 
        this.thrown = thrown;
        this.error = error;
}

var be_BECS_ThrowBack_handleThrow = function(theThrow) {
    if (null != theThrow) {
        if (theThrow instanceof be_BECS_ThrowBack) {
          if (null != theThrow.error &&
            null != theThrow.error.stack) {
            //console.log(theThrow.error.stack);
          }
          if (null != theThrow.thrown &&
              theThrow.thrown instanceof be_BEC_2_6_9_SystemException) {
              var bes = theThrow.thrown;
              bes.bem_langSet_1(
                 new be_BEC_2_4_6_TextString().beml_set_bevi_bytes(bes.bems_stringToBytes_1("js"))
                 );
              bes.bem_framesTextSet_1(new be_BEC_2_4_6_TextString().beml_set_bevi_bytes(bes.bems_stringToBytes_1(theThrow.error.stack)));
              return bes;
          } else {
            return theThrow.thrown;
          }
        } else {
          //console.log(theThrow);
          //console.log(theThrow.stack);
        }
    } else {
        //console.log("handleThrow received null");
    }
    return null;
}

be_BECS_Runtime.prototype.hashCounter = 0;//for object derived hashcodes

be_BECS_Runtime.prototype.typeRefs = function() { }

be_BECS_Runtime.prototype.minArg = 2;

be_BECS_Runtime.prototype.smnlcs = function() { }

be_BECS_Runtime.prototype.smnlecs = function() { }

be_BECS_Runtime.prototype.putNlcSourceMap = function(clname, vals) {
  be_BECS_Runtime.prototype.smnlcs[clname] = vals;
}

be_BECS_Runtime.prototype.putNlecSourceMap = function(clname, vals) {
  be_BECS_Runtime.prototype.smnlecs[clname] = vals;
}

be_BECS_Runtime.prototype.getNlcForNlec = function(clname, val) {
  var sls = be_BECS_Runtime.prototype.smnlcs[clname];
  var esls = be_BECS_Runtime.prototype.smnlecs[clname];
  if (esls !== null) {
    var eslslen = esls.length;
    for (var i = 0;i < eslslen;i++) {
      if (esls[i] == val) {
        return sls[i];
      }
    }
  }
  return -1;
}
