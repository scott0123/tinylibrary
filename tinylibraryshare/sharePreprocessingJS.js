var sharePreprocessingJS = function() {};

sharePreprocessingJS.prototype = {
    run: function(arguments) {
       arguments.completionFunction({"title": document.title, "url" : document.URL});
    } 
};

// The JavaScript file must contain a global object named "ExtensionPreprocessingJS".
var ExtensionPreprocessingJS = new sharePreprocessingJS;
