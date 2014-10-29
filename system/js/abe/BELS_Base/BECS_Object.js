
var abe_BELS_Base_BECS_Object = function() { }

abe_BELS_Base_BECS_Object.prototype.becs_insts = function() { }

abe_BELS_Base_BECS_Object.prototype.bems_bytesToString_2 = function(arr, len) {
    for (var i=0, l=len, s='', c; c = arr[i++];)
    s += String.fromCharCode(
        c > 0xdf && c < 0xf0 && i < l-1
            ? (c & 0xf) << 12 | (arr[i++] & 0x3f) << 6 | arr[i++] & 0x3f
        : c > 0x7f && i < l
            ? (c & 0x1f) << 6 | arr[i++] & 0x3f
        : c
    );
    return(s);
}

abe_BELS_Base_BECS_Object.prototype.bems_stringToJsString_1 = function(str) {
    return (abe_BELS_Base_BECS_Object.prototype.bems_bytesToString_2(str.bevi_bytes, str.bevp_size.bevi_int));
}

abe_BELS_Base_BECS_Object.prototype.bems_bytesToString_1 = function(arr) {
    return (abe_BELS_Base_BECS_Object.prototype.bems_bytesToString_2(arr, arr.length));
}

abe_BELS_Base_BECS_Object.prototype.bems_stringToBytes_1 = function(str) {
    var utf8 = [];
    for (var i=0; i < str.length; i++) {
        var charcode = str.charCodeAt(i);
        if (charcode < 0x80) utf8.push(charcode);
        else if (charcode < 0x800) {
            utf8.push(0xc0 | (charcode >> 6), 
                      0x80 | (charcode & 0x3f));
        }
        else if (charcode < 0xd800 || charcode >= 0xe000) {
            utf8.push(0xe0 | (charcode >> 12), 
                      0x80 | ((charcode>>6) & 0x3f), 
                      0x80 | (charcode & 0x3f));
        }
        // surrogate pair
        else {
            i++;
            // UTF-16 encodes 0x10000-0x10FFFF by
            // subtracting 0x10000 and splitting the
            // 20 bits of 0x0-0xFFFFF into two halves
            charcode = 0x10000 + (((charcode & 0x3ff)<<10)
                      | (str.charCodeAt(i) & 0x3ff))
            utf8.push(0xf0 | (charcode >>18), 
                      0x80 | ((charcode>>12) & 0x3f), 
                      0x80 | ((charcode>>6) & 0x3f), 
                      0x80 | (charcode & 0x3f));
        }
    }
    return utf8;
}
