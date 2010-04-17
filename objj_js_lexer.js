t = [/$/mg,/((?:0x[0-9A-Fa-f]+)|(?:\d+(?:(?:[.]\d+)?(?:[eE][+-]?\d+)?)?))/gm,/(,)/gm,/(:)/gm,/(;)/gm,/(\()/gm,/(\))/gm,/(\{)/gm,/(\})/gm,/(\[)/gm,/(\])/gm,/(\.\.\.)/gm,/(\.)/gm,/(\/(?:[^\/\\\n]|\\.)*\/[gim]*(?!\s*[\{\[\(\w]))/gm,/((?:@?"(?:[^"\\\n]|\\.)*?")|(?:'(?:[^'\\\n]|\\.)*?'))/gm,/(\bfunction(?![$\w]))/gm,/(\bvar(?![$\w]))/gm,/(\bcase(?![$\w]))/gm,/(\bdefault(?![$@\w]))/gm,/(\bswitch(?![$\w]))/gm,/(\bbreak(?![$\w]))/gm,/(\bcontinue(?![$\w]))/gm,/(\binstanceof(?![$\w]))/gm,/(\bsuper(?![$\w]))/gm,/(\breturn(?![$\w]))/gm,/(\bif(?![$\w]))/gm,/(\belse(?![$\w]))/gm,/(\bdo(?![$\w]))/gm,/(\bwhile(?![$\w]))/gm,/(\bfor(?![$\w]))/gm,/(\btry(?![$\w]))/gm,/(\bcatch(?![$\w]))/gm,/(\bfinally(?![$\w]))/gm,/(\bthrow(?![$\w]))/gm,/(\bnew(?![$\w]))/gm,/(\btypeof(?![$\w]))/gm,/(\bwith(?![$\w]))/gm,/(\bin(?![$\w]))/gm,/(\bdelete(?![$\w]))/gm,/(\blong(?![$\w]))/gm,/(\bint(?![$\w]))/gm,/(\bchar(?![$\w]))/gm,/(\bshort(?![$\w]))/gm,/(\bunsigned(?![$\w]))/gm,/([A-Za-z_$][$\w]*)/gm,/(===)/gm,/(==)/gm,/(=)/gm,/(\+=)/gm,/(\+\+)/gm,/(\+)/gm,/(-=)/gm,/(--)/gm,/(-)/gm,/(\>\>\>=)/gm,/(\>\>\>)/gm,/(\<\<=)/gm,/(\>\>=)/gm,/(\*=)/gm,/(\/=)/gm,/(%=)/gm,/(&=)/gm,/(\|=)/gm,/(\^=)/gm,/(\>=)/gm,/(\<=)/gm,/(!==)/gm,/(!=)/gm,/(\<\<)/gm,/(\>\>)/gm,/(&&)/gm,/(\|\|)/gm,/(\>)/gm,/(\<)/gm,/(\*)/gm,/(\/)/gm,/(%)/gm,/(~)/gm,/(!)/gm,/(&)/gm,/(\|)/gm,/(\^)/gm,/(\?)/gm,/(@implementation(?![$\w]))/gm,/(@accessors(?![$\w]))/gm,/(@outlet(?![$\w]))/gm,/(@action(?![$\w]))/gm,/(@class(?![$\w]))/gm,/(@end(?![$\w]))/gm,/(@import\s*\<[^\n]*?\>)/gm,/(@import(?![$\w]))/gm,/(@selector(?![$\w]))/gm,/(@each(?![$\w]))/gm];
var anyToken = /((?:0x[0-9A-Fa-f]+)|(?:\d+(?:(?:[.]\d+)?(?:[eE][+-]?\d+)?)?))|(,)|(:)|(;)|(\()|(\))|(\{)|(\})|(\[)|(\])|(\.\.\.)|(\.)|(\/(?:[^\/\\\n]|\\.)*\/[gim]*(?!\s*[\{\[\(\w]))|((?:@?"(?:[^"\\\n]|\\.)*?")|(?:'(?:[^'\\\n]|\\.)*?'))|(\bfunction(?![$\w]))|(\bvar(?![$\w]))|(\bcase(?![$\w]))|(\bdefault(?![$@\w]))|(\bswitch(?![$\w]))|(\bbreak(?![$\w]))|(\bcontinue(?![$\w]))|(\binstanceof(?![$\w]))|(\bsuper(?![$\w]))|(\breturn(?![$\w]))|(\bif(?![$\w]))|(\belse(?![$\w]))|(\bdo(?![$\w]))|(\bwhile(?![$\w]))|(\bfor(?![$\w]))|(\btry(?![$\w]))|(\bcatch(?![$\w]))|(\bfinally(?![$\w]))|(\bthrow(?![$\w]))|(\bnew(?![$\w]))|(\btypeof(?![$\w]))|(\bwith(?![$\w]))|(\bin(?![$\w]))|(\bdelete(?![$\w]))|(\blong(?![$\w]))|(\bint(?![$\w]))|(\bchar(?![$\w]))|(\bshort(?![$\w]))|(\bunsigned(?![$\w]))|([A-Za-z_$][$\w]*)|(===)|(==)|(=)|(\+=)|(\+\+)|(\+)|(-=)|(--)|(-)|(\>\>\>=)|(\>\>\>)|(\<\<=)|(\>\>=)|(\*=)|(\/=)|(%=)|(&=)|(\|=)|(\^=)|(\>=)|(\<=)|(!==)|(!=)|(\<\<)|(\>\>)|(&&)|(\|\|)|(\>)|(\<)|(\*)|(\/)|(%)|(~)|(!)|(&)|(\|)|(\^)|(\?)|(@implementation(?![$\w]))|(@accessors(?![$\w]))|(@outlet(?![$\w]))|(@action(?![$\w]))|(@class(?![$\w]))|(@end(?![$\w]))|(@import\s*\<[^\n]*?\>)|(@import(?![$\w]))|(@selector(?![$\w]))|(@each(?![$\w]))/mg;
var tokens = null;
var numbers = [];
var comments = [/\/\/.*\n?/mg,/\/\*(?:.|\n)*?\*\/(?=.|$)/mg];
onmessage = function(message){
var str = message.data;
for(var k = 0; k < comments.length; k++){
comments[k].test("");
if(comments[k].test(str))
str = str.split(comments[k]).join("");
}
tokens = str.match(anyToken);
postMessage(JSON.stringify(tokens));
var start = new Date().getTime();
var now;
for (var j = 0; j < tokens.length; j++)
{
if ((now = new Date().getTime()) - start > 50)
{
start = now;
postMessage(JSON.stringify(numbers));
numbers = [];
}
var tok = tokens[j];
for(var i = 1; i < t.length; i++)
{
t[i].test("");
if(t[i].test(tok)){numbers.push(i);break;}
}
}
numbers.push(0);
postMessage(JSON.stringify(numbers));
return;
}