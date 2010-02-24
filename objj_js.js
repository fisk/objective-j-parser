function objj_compiler(str, path, bundle, callback)
{
this._lexer = new Worker('objj_js_lexer.js');
this._parser = new Worker('objj_js_parser.js');
var parser = this._parser;
this._executable = null;
this._code = str;
this._dependencies = [];
var dependencies = this._dependencies;
this._bundle = bundle;
this._path = path;

this._lexer.onmessage = function(message)
{
parser.postMessage(message.data);
}

this._parser.onmessage = function(message)
{
callback(new Executable(message.data, dependencies));
}
}
objj_compiler.prototype.parse = function()
{
this._start = new Date();
this._startLexing = this._start;
this._lexer.postMessage(this._code);
}
function preprocess(str, path, bundle, callback)
{
new objj_compiler(str, path, bundle, callback).parse();
}