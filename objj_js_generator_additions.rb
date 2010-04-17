#!ruby
# coding: utf-8
# 
# objj_js_generator.rb
#
# Created by Erik Österlund on 1/14/10.
# Copyright 2010 Växjö Universitet. All rights reserved.
#

require 'js_interpreter_generator'
include LALR

class ObjjJsGenerator < InterpreterGenerator

  def additional_rules()
  
rule(:JS_ELEMENT => :OBJJ_IMPL){'@1.e();'}

# Implementation without inheritance or category
rule(:OBJJ_IMPL => [OBJJ_IMPLEMENTATION, JS_IDENTIFIER, :OBJJ_IVAR_BLOCK, :OBJJ_METHOD_BLOCK]){
  'context._instanceMethods = [];
  context._classMethods = [];
  context._currentClass = $2;
  context._currentSuperClass = "objj_getClass(\"" + $2 + "\").super_class";
  context._currentSuperMetaClass = "objj_getMetaClass(\"" + $2 + "\").super_class";
  $.push("{var the_class = objj_allocateClassPair(Nil,\"");
  $.push($2);
  $.push("\");var meta_class = the_class.isa;");
  @3.e();
  $.push("objj_registerClassPair(the_class);");
  @4.e();
  $.push("};");'
}
# Implementation with inheritance
rule(:OBJJ_IMPL => [OBJJ_IMPLEMENTATION, JS_IDENTIFIER, JS_COLON, JS_IDENTIFIER, :OBJJ_IVAR_BLOCK, :OBJJ_METHOD_BLOCK]){
  'context._instanceMethods = [];
  context._classMethods = [];
  context._currentClass = $2;
  context._currentSuperClass = "objj_getClass(\"" + $2 + "\").super_class";
  context._currentSuperMetaClass = "objj_getMetaClass(\"" + $2 + "\").super_class";
  $.push("{var the_class = objj_allocateClassPair(");
  $.push($4);
  $.push(",\"");
  $.push($2);
  $.push("\");var meta_class = the_class.isa;");
  @5.e();
  $.push("objj_registerClassPair(the_class);");
  @6.e();
  $.push("};");'
}
# Implementation with category
rule(:OBJJ_IMPL => [OBJJ_IMPLEMENTATION, JS_IDENTIFIER, JS_LPAR, JS_IDENTIFIER, JS_RPAR, :OBJJ_METHOD_BLOCK]){
  'context._instanceMethods = [];
  context._classMethods = [];
  context._currentClass = $2;
  context._currentSuperClass = "objj_getClass(\"" + $2 + "\").super_class";
  context._currentSuperMetaClass = "objj_getMetaClass(\"" + $2 + "\").super_class";
  $.push("{var the_class = objj_getClass(\"");
  $.push($2);
  $.push("\");var meta_class = the_class.isa;");
  @6.e();
  $.push("};");'
}


# Instance variable declarations
rule(:OBJJ_IVAR_BLOCK => [JS_MLPAR, :OBJJ_IVAR_DECL_LIST, JS_MRPAR]){
  '$.push("class_addIvars(the_class, [");
  @2.e();
  $.push("]);");'
}
rule(:OBJJ_IVAR_BLOCK => [JS_MLPAR, JS_MRPAR]){
  ''
}
rule(:OBJJ_IVAR_BLOCK => Epsilon.instance) {''}

rule(:OBJJ_IVAR_DECL_LIST => [:OBJJ_IVAR_DECL_LIST, :OBJJ_IVAR_DECL]){
  '@1.e();
  $.push(",");
  @2.e();'
}
rule(:OBJJ_IVAR_DECL_LIST => :OBJJ_IVAR_DECL){
  '@1.e();'
}
rule(:OBJJ_IVAR_DECL=> [:OBJJ_TYPE, JS_IDENTIFIER, :OBJJ_ACCESSORS]){
  '$.push("new objj_ivar(\"");
  $.push($2);
  $.push("\")");
  @3.e();
  if (context._accessors)
  {
    var property = context._accessors["property"] || $2;
    var getterName = context._accessors["getter"] || property;
    var getter = "new objj_method(sel_getUid(\"" + getterName + 
    "\"), function(self, _cmd){with(self){return " + $2 + ";}}, [\"id\"])";
    context._instanceMethods.push(getter);
    if (!context._accessors["readonly"])
    {
      var setterName = context._accessors["setter"];
      if (!setterName)
      {
        var start = property.charAt(0) == "_" ? 1 : 0;
        setterName = (start ? "_" : "") + "set" + property.substr(start, 1).toUpperCase() + property.substring(start + 1) + ":";
      }
      var setterCore = "";
      if (context._accessors["copy"]){
        setterCore = "if(" + $2 + "!== value)" + $2 + "=objj_msgSend(value, \"copy\")";
      }else{
        setterCore = $2 + "=value";
      }
      var setter = "new objj_method(sel_getUid(\"" + setterName + 
        "\"), function(self, _cmd, value){with(self){" + setterCore + ";}}, [\"void\", \"id\"])";
      context._instanceMethods.push(setter);
    }
  }'
}

rule(:OBJJ_IVAR_DECL=> [OBJJ_OUTLET, :OBJJ_TYPE, JS_IDENTIFIER, :OBJJ_ACCESSORS]){
  '$.push("new objj_ivar(\"");
  $.push($3);
  $.push("\")");
  @4.e();
  if (context._accessors)
  {
    var property = context._accessors["property"] || $3;
    var getterName = context._accessors["getter"] || property;
    var getter = "new objj_method(sel_getUid(\"" + getterName + 
    "\"), function(self, _cmd){with(self){return " + $3 + ";}}, [\"id\"])";
    context._instanceMethods.push(getter);
    if (!context._accessors["readonly"])
    {
      var setterName = context._accessors["setter"];
      if (!setterName)
      {
        var start = property.charAt(0) == "_" ? 1 : 0;
        setterName = (start ? "_" : "") + "set" + property.substr(start, 1).toUpperCase() + property.substring(start + 1) + ":";
      }
      var setterCore = "";
      if (context._accessors["copy"]){
        setterCore = "if(" + $3 + "!== value)" + $3 + "=objj_msgSend(value, \"copy\")";
      }else{
        setterCore = $3 + "=value";
      }
      var setter = "new objj_method(sel_getUid(\"" + setterName + 
        "\"), function(self, _cmd, value){with(self){" + setterCore + ";}}, [\"void\", \"id\"])";
      context._instanceMethods.push(setter);
    }
  }'
}

# Accessors
rule(:OBJJ_ACCESSORS => :JS_SEPARATOR) {
  'context._accessors = null;'
}
rule(:OBJJ_ACCESSORS => [OBJJ_ACCESSORS, JS_LPAR, :OBJJ_ACCESSOR_PROPS, JS_RPAR, :JS_SEPARATOR]) {
  'context._accessors = {};
  @3.e();'
}
rule(:OBJJ_ACCESSORS => [OBJJ_ACCESSORS, :JS_SEPARATOR]) {
  'context._accessors = {};'
}

rule(:OBJJ_ACCESSOR_PROPS => [:OBJJ_ACCESSOR_PROPS, JS_COMMA, :OBJJ_ACCESSOR_PROP]) {
  '@1.e();@3.e();'
}
rule(:OBJJ_ACCESSOR_PROPS => [:OBJJ_ACCESSOR_PROP]) {
  '@1.e();'
}

rule(:OBJJ_ACCESSOR_PROP => [JS_IDENTIFIER, JS_EQ, JS_IDENTIFIER]) {
  'context._accessors[$1] = $3;'
}
rule(:OBJJ_ACCESSOR_PROP => [JS_IDENTIFIER, JS_EQ, JS_IDENTIFIER, JS_COLON]) {
  'context._accessors[$1] = $3 + ":";'
}
rule(:OBJJ_ACCESSOR_PROP => [JS_IDENTIFIER]) {
  'context._accessors[$1] = true;'
}


rule(:OBJJ_METHOD_BLOCK => [:OBJJ_METHOD_DECL_LIST, OBJJ_END]){
  '@1.e();
  if(context._instanceMethods.length){
  $.push("class_addMethods(the_class, [");
  for (var i = 0; i < context._instanceMethods.length; i++)
  {
    $.push(context._instanceMethods[i]);
    if (i+1 < context._instanceMethods.length)
      $.push(",");
  }
  $.push("]);");
  }
  if(context._classMethods.length){
  $.push("class_addMethods(meta_class, [");
  for (var i = 0; i < context._classMethods.length; i++)
  {
    $.push(context._classMethods[i]);
    if (i+1 < context._classMethods.length)
      $.push(",");
  }
  $.push("]);");
  }'
}
rule(:OBJJ_METHOD_BLOCK => [OBJJ_END]){
  ''
}

rule(:OBJJ_METHOD_DECL_LIST => [:OBJJ_METHOD_DECL_LIST, :OBJJ_METHOD_DECL]){
  '@1.e();@2.e();'
}
rule(:OBJJ_METHOD_DECL_LIST => :OBJJ_METHOD_DECL){
  '@1.e();'
}

# Methods
rule(:OBJJ_METHOD_DECL => [:OBJJ_M_TYPE, :OBJJ_M_ARG_TYPE, :JS_KEY_IDENTIFIER, :OBJJ_METHOD_REST, :JS_BLOCK]){
  '@1.e();
  context._methArgsType = [];
  @2.e();
  
  var meth = "new objj_method(sel_getUid(\"" +
  context.getSymbol(@3) + context.getSymbol(@4) +
  "\"), function(self, _cmd){with(self)" +
  context.getSymbol(@5) +
  "}, [" + context._methArgsType.join(",") + "])";
  
  $1.push(meth);'
}
rule(:OBJJ_METHOD_DECL => [:OBJJ_M_TYPE, :OBJJ_M_ARG_TYPE, :OBJJ_METHOD_PARAM_LIST, :OBJJ_METHOD_REST, :JS_BLOCK]){
  '@1.e();
  context._methArgsSel = [];
  context._methArgsType = [];
  context._methArgs = [];
  @2.e();
  @3.e();
  
  var meth = "new objj_method(sel_getUid(\"" +
  context._methArgsSel.join("") +
  "\"), function(self, _cmd, " +
  context._methArgs.join(",") + context.getSymbol(@4) +
  "){with(self)" +
  context.getSymbol(@5) + 
  "}, [" + context._methArgsType.join(",") + "])";
  
  $1.push(meth);'
}

rule(:OBJJ_METHOD_REST => [JS_COMMA, :JS_REST]){''}
rule(:OBJJ_METHOD_REST => [:JS_REST]){''}
rule(:OBJJ_METHOD_REST => Epsilon.instance){''}

rule(:OBJJ_METHOD_PARAM_LIST => [:OBJJ_METHOD_PARAM_LIST, :OBJJ_METHOD_PARAM]){
  '@1.e();@2.e();'
}
rule(:OBJJ_METHOD_PARAM_LIST => :OBJJ_METHOD_PARAM){
  '@1.e();'
}
rule(:OBJJ_METHOD_PARAM => [:JS_KEY_IDENTIFIER, JS_COLON, :OBJJ_M_ARG_TYPE, JS_IDENTIFIER]){
  'context._methArgsSel.push(context.getSymbol(@1) + ":");
  context._methArgs.push($4);
  @3.e();'
}
rule(:OBJJ_METHOD_PARAM => [JS_COLON, :OBJJ_M_ARG_TYPE, JS_IDENTIFIER]){
  'context._methArgsSel.push(":");
  context._methArgs.push($3);
  @2.e();'
}

rule(:OBJJ_M_TYPE => [JS_ADD]){
  '$$ = context._classMethods;
  context._classMethod = true;'
}
rule(:OBJJ_M_TYPE => [JS_SUB]){
  '$$ = context._instanceMethods;
  context._classMethod = false;'
}
rule(:OBJJ_M_ARG_TYPE => [JS_LPAR, :OBJJ_TYPE, JS_RPAR]){
  '@2.e();context._methArgsType.push("\"" + $2 + "\"");'
}
rule(:OBJJ_M_ARG_TYPE => [JS_LPAR, OBJJ_ACTION, JS_RPAR]){
  'context._methArgsType.push("\"void\"");'
}
rule(:OBJJ_M_ARG_TYPE => Epsilon.instance){''}

rule(:OBJJ_TYPE => [:OBJJ_TYPE, JS_MUL]){
  '@1.e();
  $$ = $1 + "*";'
}
rule(:OBJJ_TYPE => JS_IDENTIFIER){
  '$$ = $1;'
}
rule(:OBJJ_TYPE => [JS_LONG, JS_LONG]){
  '$$ = "long long";'
}
rule(:OBJJ_TYPE => [:OBJJ_TYPE_INTEGER]){
  '$$ = $1;'
}
rule(:OBJJ_TYPE => [JS_UNSIGNED, :OBJJ_TYPE_INTEGER]){
  '$$ = "unsigned " + $2;'
}
rule(:OBJJ_TYPE => [JS_UNSIGNED]){
  '$$ = "unsigned";'
}
rule(:OBJJ_TYPE_INTEGER => JS_LONG) {'$$ = "long";'}
rule(:OBJJ_TYPE_INTEGER => JS_INT) {'$$ = "int";'}
rule(:OBJJ_TYPE_INTEGER => JS_CHAR) {'$$ = "char";'}
rule(:OBJJ_TYPE_INTEGER => JS_SHORT) {'$$ = "short";'}

# Selector stuff
rule(:JS_PRIMARY_EXPR => :OBJJ_SEL) {
  '@1.e();'
}
rule(:OBJJ_SEL => [OBJJ_SELECTOR, JS_LPAR, :JS_KEY_IDENTIFIER, JS_RPAR]) {
  '$.push("sel_getUid(\"");
  @3.e();
  $.push("\")");'
}
rule(:OBJJ_SEL => [OBJJ_SELECTOR, JS_LPAR, :SEL_PART_LIST, JS_RPAR]) {
  '$.push("sel_getUid(\"");
  @3.e();
  $.push("\")");'
}
rule(:SEL_PART_LIST => [:SEL_PART_LIST, :SEL_PART]) {
  '@1.e();@2.e();'
}
rule(:SEL_PART_LIST => [:SEL_PART]) {
  '@1.e();'
}
rule(:SEL_PART => [:JS_KEY_IDENTIFIER, JS_COLON]) {
  '@1.e();$.push(":");'
}
rule(:SEL_PART => [JS_COLON]) {
  '$.push(":");'
}

# Method invocation
rule(:JS_CALL_EXPR => [JS_ALPAR, JS_SUPER, :JS_KEY_IDENTIFIER, JS_ARPAR]) {
  '$.push("objj_msgSendSuper({receiver:self, super_class:");
  if (context._classMethod)
  {
    $.push(context._currentSuperMetaClass);
  } else {
    $.push(context._currentSuperClass);
  }
  $.push("},\"");
  @3.e();
  $.push("\")");'
}
rule(:JS_CALL_EXPR => [JS_ALPAR, JS_SUPER, :OBJJ_METHOD_ARG_LIST, :OBJJ_METHODCALL_REST, JS_ARPAR]) {
  'var oldSel = context._methArgsSel, oldArgs = context._methArgs;
  context._methArgsSel = [];
  context._methArgs = [];
  @3.e();
  @4.e();
  
  $.push("objj_msgSendSuper({receiver:self, super_class:");
  if (context._classMethod)
  {
    $.push(context._currentSuperMetaClass);
  } else {
    $.push(context._currentSuperClass);
  }
  $.push("},\"");
  $.push(context._methArgsSel.join(""));
  $.push("\"");
  var buff = context._methArgs;
  for(var i = 0; i < buff.length; i++)
  {
    $.push(",");
    buff[i].e();
  }
  $.push(")");
  context._methArgsSel = oldSel;
  context._methArgs = oldArgs;'
}
rule(:JS_CALL_EXPR => [JS_ALPAR, :JS_ASSIGN_EXPR, :JS_KEY_IDENTIFIER, JS_ARPAR]) {
  '$.push("objj_msgSend(");
  @2.e();
  $.push(",\"");
  @3.e();
  $.push("\")");'
}
rule(:JS_CALL_EXPR => [JS_ALPAR, :JS_ASSIGN_EXPR, :OBJJ_METHOD_ARG_LIST, :OBJJ_METHODCALL_REST, JS_ARPAR]) {
  'var oldSel = context._methArgsSel, oldArgs = context._methArgs;
  context._methArgsSel = [];
  context._methArgs = [];
  @3.e();
  @4.e();
  
  $.push("objj_msgSend(");
  @2.e();
  $.push(",\"");
  $.push(context._methArgsSel.join(""));
  $.push("\"");
  var buff = context._methArgs;
  for(var i = 0; i < buff.length; i++)
  {
    $.push(",");
    buff[i].e();
  }
  $.push(")");
  context._methArgsSel = oldSel;
  context._methArgs = oldArgs;'
}

rule(:OBJJ_METHOD_ARG_LIST => [:OBJJ_METHOD_ARG_LIST, :OBJJ_METHOD_ARG]) {
  '@1.e();@2.e();'
}
rule(:OBJJ_METHOD_ARG_LIST => [:OBJJ_METHOD_ARG]) {
  '@1.e();'
}

rule(:OBJJ_METHOD_ARG => [:JS_KEY_IDENTIFIER, JS_COLON, :JS_ASSIGN_EXPR]) {
  'context._methArgsSel.push(context.getSymbol(@1) + ":");
  context._methArgs.push(@3);'
}
rule(:OBJJ_METHOD_ARG => [JS_COLON, :JS_ASSIGN_EXPR]) {
  'context._methArgsSel.push(":");
  context._methArgs.push(@2);'
}

rule(:OBJJ_METHODCALL_REST => Epsilon.instance){''}
rule(:OBJJ_METHODCALL_REST => [JS_COMMA, :JS_ARG_LIST]){
  'context._methArgs.push(@2);'
}

# Import
rule(:JS_ELEMENT => :OBJJ_IMPORT) {
  '@1.e();'
}

rule(:OBJJ_IMPORT => [OBJJ_IMPORT_TAG_LITERAL]){
  '$.push("objj_executeFile(\"");
  var url = /\<(.*)\>/.exec($1)[1];
  $.push(url);
  $.push("\", false);");
  context._dependencies.push(new FileDependency(new CFURL(url), false));'
}

rule(:OBJJ_IMPORT => [OBJJ_IMPORT, JS_STRING_LITERAL]){
  '$.push("objj_executeFile(\"");
  var url = $2.slice(1, $2.length-1);
  $.push(url);
  $.push("\", true);");
  context._dependencies.push(new FileDependency(new CFURL(url), true));'
}

rule(:JS_KEY_IDENTIFIER => JS_IDENTIFIER){'$.push($1);'}
rule(:JS_KEY_IDENTIFIER => JS_NEW){'$.push("new");'}
rule(:JS_KEY_IDENTIFIER => JS_WITH){'$.push("with");'}
rule(:JS_KEY_IDENTIFIER => JS_CASE){'$.push("case");'}
rule(:JS_KEY_IDENTIFIER => JS_SWITCH){'$.push("switch");'}
rule(:JS_KEY_IDENTIFIER => JS_DEFAULT){'$.push("default");'}
rule(:JS_KEY_IDENTIFIER => JS_SUPER){'$.push("super");'}
rule(:JS_KEY_IDENTIFIER => JS_INSTANCEOF){'$.push("instanceof");'}
rule(:JS_KEY_IDENTIFIER => JS_BREAK){'$.push("break");'}
rule(:JS_KEY_IDENTIFIER => JS_CONTINUE){'$.push("continue");'}
rule(:JS_KEY_IDENTIFIER => JS_RETURN){'$.push("return");'}
rule(:JS_KEY_IDENTIFIER => JS_IF){'$.push("if");'}
rule(:JS_KEY_IDENTIFIER => JS_ELSE){'$.push("else");'}
rule(:JS_KEY_IDENTIFIER => JS_DO){'$.push("do");'}
rule(:JS_KEY_IDENTIFIER => JS_WHILE){'$.push("while");'}
rule(:JS_KEY_IDENTIFIER => JS_FOR){'$.push("for");'}
rule(:JS_KEY_IDENTIFIER => JS_TRY){'$.push("try");'}
rule(:JS_KEY_IDENTIFIER => JS_CATCH){'$.push("catch");'}
rule(:JS_KEY_IDENTIFIER => JS_FINALLY){'$.push("finally");'}
rule(:JS_KEY_IDENTIFIER => JS_THROW){'$.push("throw");'}
rule(:JS_KEY_IDENTIFIER => JS_TYPEOF){'$.push("typeof");'}
rule(:JS_KEY_IDENTIFIER => JS_DELETE){'$.push("delete");'}
rule(:JS_KEY_IDENTIFIER => JS_IN){'$.push("in");'}
rule(:JS_KEY_IDENTIFIER => JS_VAR){'$.push("var");'}
rule(:JS_KEY_IDENTIFIER => :OBJJ_TYPE_INTEGER){'$.push($1);'}

# Class
rule(:JS_ELEMENT => :OBJJ_CLASS) {
  ''
}
rule(:OBJJ_CLASS => [OBJJ_CLASS, JS_IDENTIFIER, :JS_SEPARATOR]) {
  ''
}

# @each

rule(:JS_ITER_STATEMENT => [OBJJ_EACH, JS_LPAR, :OBJJ_POTENTIAL_VAR, :JS_IDENTIFIER_LIST, JS_IN, :JS_EXPR, JS_RPAR, :JS_STATEMENT]) {
  'var oldIdentifiers = context._eachIdentifiers;
  context._eachIdentifiers = [];
  @4.e();
  var enumeratorName = "$OBJJ_GENERATED_FAST_ENUMERATOR_" + (this._eachNumIterators++);
  $.push("var " + enumeratorName + " = new objj_fastEnumerator(");
  @6.e();
  $.push(");for(");
  @3.e();
  $.push(context._eachIdentifiers.join(","));
  $.push(";" + enumeratorName + ".i < " + enumeratorName + ".l");
  $.push("||" + enumeratorName + ".e() && ((");
  
  var len = context._eachIdentifiers.length;
  var args = [];
  for (var i = 0; i < len; i++)
  {
    var tmp = [];
    tmp.push(context._eachIdentifiers[i]);
    tmp.push("=");
    tmp.push(enumeratorName);
    tmp.push(".o");
    tmp.push(i);
    tmp.push("[");
    tmp.push(enumeratorName);
    tmp.push(".i]");
    args[args.length] = tmp.join("");
  }
  $.push(args.join(","));
  
  $.push(")||YES);");
  $.push("++" + enumeratorName + ".i)");
  @8.e();'
}
rule(:OBJJ_POTENTIAL_VAR => JS_VAR) {'$.push("var ");'}
rule(:OBJJ_POTENTIAL_VAR => Epsilon.instance) {''}

rule(:JS_IDENTIFIER_LIST => [JS_IDENTIFIER]){
  'context._eachIdentifiers.push($1);'
}
rule(:JS_IDENTIFIER_LIST => [:JS_IDENTIFIER_LIST, JS_COMMA, JS_IDENTIFIER]){
  '@1.e();context._eachIdentifiers.push($3);'
}

# Unary pointer operators
rule(:JS_UNARY_EXPR => [JS_BAND, :JS_LHS_EXPR]) {
  '$.push("function(__v){if(__v)");
  @2.e();
  $.push("=__v;return ");
  @2.e();
  $.push("}");'
}

rule(:JS_UNARY_EXPR => :JS_UNARY_DEREF) {
  '@1.e();'
}
rule(:JS_UNARY_DEREF => [JS_MUL, :JS_LHS_EXPR]) {
  '@2.e();
  $.push("()");'
}

rule(:JS_ASSIGN_EXPR => [:JS_UNARY_DEREF, JS_EQ, :JS_ASSIGN_EXPR]) {
  'var tmp = context.getSymbol(@1);
  $.push(tmp.slice(0, tmp.length-1));
  $.push("(");
  @3.e();
  $.push(")");'
}

    compiler("compiler") do
      'function compiler()
      {
        this._currentClass = null;
        this._currentSuperClass = null;
        this._instanceMethods = [];
        this._classMethods = [];
        this._dependencies = [];
        this._eachNumIterators = 0;
      }
      
      compiler.prototype.getSymbol = function(symbol)
      {
        var buffer = $;
        $ = [];
        symbol.e();
        var result = $;
        $ = buffer;
        return result.join("");
      };'
    end
    
    header do
      'exports.Preprocessor = Preprocessor;

       Preprocessor.Flags = { };

       Preprocessor.Flags.IncludeDebugSymbols      = 1 << 0;
       Preprocessor.Flags.IncludeTypeSignatures    = 1 << 1;'
    end
    
    footer do
      ''
    end
    
  end

end