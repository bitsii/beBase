
//bevt_4_tmpvar_phold = (new abe_BEL_4_Base_BEC_4_6_TextString(bels_1)).bem_new_0();
//bevt_5_tmpvar_phold = (new abe_BEL_4_Base_BEC_4_3_MathInt(1)).bem_new_0();


var BECS_Object = function() { }

var BEC_Object = function() { }
//extend BECS_Object
BEC_Object.prototype = new BECS_Object();

var BEC_Int = function() { }
//extend BECS_Object
BEC_Int.prototype = new BEC_Object(); 
BEC_Int.prototype.printIt = function() {
    console.log(this.ival);
}
BEC_Int.prototype.setIval = function(ival) {
    this.ival = ival;
    return this;
}

BEC_Int.prototype.retThis = function(ival) {
    return this;
}



var i = (new BEC_Int().setIval(10)).retThis();
i.printIt();


