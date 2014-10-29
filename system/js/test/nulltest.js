
var BECS_Object = function() { }

BECS_Object.prototype.testit = function() {
    var boo;
    if (boo == null) {
        console.log("boo is null");
    }
    if (this.foo == null) {
        console.log("foo is null");
    }
    if (this.pfoo == null) {
        console.log("early pfoo null");
    }
    BECS_Object.prototype.pbar = "hi";
    console.log(this.pbar);
    BECS_Object.prototype.pbar = "yo";
    console.log(this.pbar);
    console.log(BECS_Object.prototype.pbar);
    this.door = "door";
    console.log(this.door);
    console.log(BECS_Object.prototype.door);
    if (this.pfoo == null) {
        console.log("pfoo is null");
    }
    var x = 0;
    if (x == null) {
        console.log("x is null, no way");
    }
    var x = null;
    if (x == null) {
        console.log("x is null, yes way");
    }
}


BECS_Object.prototype.checkIdentity = function() {
    console.log("chkid");
    var x = {"a":0};
    var y = {"a":0};
    if (x == y) {
        console.log("x y eq");
    } else {
        console.log("x y neq");
    }
    
    if (x === y) {
        console.log("x y ideq");
    } else {
        console.log("x y idneq");
    }
    
    if (x != y) {
        console.log("x y tneq");
    } else {
        console.log("x y teq");
    }
    
    if (x !== y) {
        console.log("x y idtneq");
    } else {
        console.log("x y idteq");
    }
    
    x = y;
    console.log("now eq");
    if (x == y) {
        console.log("x y eq");
    } else {
        console.log("x y neq");
    }
    
    if (x === y) {
        console.log("x y ideq");
    } else {
        console.log("x y idneq");
    }
    
    if (x != y) {
        console.log("x y tneq");
    } else {
        console.log("x y teq");
    }
    
    if (x !== y) {
        console.log("x y idtneq");
    } else {
        console.log("x y idteq");
    }
    
}

var bo = new BECS_Object();

//bo.testit();
bo.checkIdentity();
