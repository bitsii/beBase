
var ThrowBack = function(thrown, error) { 
        this.thrown = thrown;
        this.error = error;
}

try {
    throw new ThrowBack("yo", new Error());
} catch (e) {
    console.log(e.error.stack);
}
