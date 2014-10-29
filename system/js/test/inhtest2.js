
var BECS_Object = function() { }

BECS_Object.prototype.m_sayHi = function() {
    return "hi";
}

BECS_Object.prototype.p0_supTest = BECS_Object.prototype.m_supTest;
BECS_Object.prototype.m_supTest = function() {
    return "beso";
}

BECS_Object.prototype.m_saySomething = function(something) {
    return something;
}

BECS_Object.prototype.m_setMember = function(amem) {
    this.amem = amem;
}

BECS_Object.prototype.m_getMember = function() {
    return this.amem;
}

var BEC_Object = function() { }

//extend BECS_Object
BEC_Object.prototype = new BECS_Object(); 

BEC_Object.prototype.p1_supTest = BEC_Object.prototype.m_supTest;
BEC_Object.prototype.m_supTest = function() {
    return "beo " + this.p1_supTest();
}

var BEC_SubType = function() { }

//extend BECS_Object
BEC_SubType.prototype = new BEC_Object(); 

BEC_SubType.prototype.p2_supTest = BEC_SubType.prototype.m_supTest;
BEC_SubType.prototype.m_supTest = function() {
    return "bes " + this.p2_supTest();
}

var so = new BECS_Object();
var co = new BEC_Object();
var cs = new BEC_SubType();

console.log(so.m_sayHi());
console.log(so.m_saySomething("boo"));
so.m_setMember("yo");
console.log(so.m_getMember());

console.log(so.m_supTest());

console.log(co.m_supTest());
co.m_setMember("oy");
console.log(so.m_getMember());
console.log(co.m_getMember());

console.log(cs.m_supTest());


