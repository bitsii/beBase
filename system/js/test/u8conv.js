

var array = [72,105,0];
var str = "";
for( var i = 0, len = array.length; i < len; ++i ) {
    var pt = array[i].toString(16);
    if (pt.length < 2) {
        pt = "0" + pt;
    }
    str += ("%" + pt)
}

str = decodeURIComponent(str);

console.log(str);
