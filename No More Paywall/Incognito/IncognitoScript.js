var GetURL = function() {};

GetURL.prototype = {
    
run: function(arguments) {
    arguments.completionFunction({ "URL" : document.URL , "title": document.title });
    
},
    
finalize: function(arguments) {
    var message = arguments["statusMessage"];
    
    if (message) {
        alert(message);
    }
}
    
};

var ExtensionPreprocessingJS = new GetURL;

