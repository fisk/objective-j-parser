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


class InterpreterGenerator
  
  JS_IDENTIFIER = /[A-Za-z_$][$\w]*/
  JS_FUNCTION = /\bfunction(?![$\w])/
  JS_VAR = /\bvar(?![$\w])/
  JS_NUMERIC_LITERAL = /(?:0x[0-9A-Fa-f]+)|(?:\d+(?:(?:[.]\d+)?(?:[eE][+-]?\d+)?)?)/
  JS_STRING_LITERAL = /(?:@?"(?:[^"\\\n]|\\.)*?")|(?:'(?:[^'\\\n]|\\.)*?')/
  OBJJ_IMPORT_TAG_LITERAL = /@import\s*\<[^\n]*?\>/
  JS_CASE = /\bcase(?![$\w])/
  JS_SWITCH = /\bswitch(?![$\w])/
  JS_DEFAULT = /\bdefault(?![$@\w])/
  JS_SUPER = /\bsuper(?![$\w])/
  JS_INSTANCEOF = /\binstanceof(?![$\w])/
  JS_BREAK = /\bbreak(?![$\w])/
  JS_CONTINUE = /\bcontinue(?![$\w])/
  JS_RETURN = /\breturn(?![$\w])/
  JS_IF = /\bif(?![$\w])/
  JS_ELSE = /\belse(?![$\w])/
  JS_DO = /\bdo(?![$\w])/
  JS_WHILE = /\bwhile(?![$\w])/
  JS_FOR = /\bfor(?![$\w])/
  JS_TRY = /\btry(?![$\w])/
  JS_CATCH = /\bcatch(?![$\w])/
  JS_FINALLY = /\bfinally(?![$\w])/
  JS_THROW = /\bthrow(?![$\w])/
  JS_REGEX = /\/(?:[^\/\\\n]|\\.)*\/[gim]*(?!\s*[\{\[\(\w])/
  JS_NEW = /\bnew(?![$\w])/
  JS_TYPEOF = /\btypeof(?![$\w])/
  JS_DELETE = /\bdelete(?![$\w])/
  JS_IN = /\bin(?![$\w])/
  JS_RSRSRSEQ = /\>\>\>=/
  JS_RSRSRS = /\>\>\>/
  JS_LSLSEQ = /\<\<=/
  JS_RSRSEQ = /\>\>=/
  JS_MULEQ = /\*=/
  JS_DIVEQ = /\/=/
  JS_MODEQ = /%=/
  JS_ADDEQ = /\+=/
  JS_SUBEQ = /-=/
  JS_BANDEQ = /&=/
  JS_BOREQ = /\|=/
  JS_BXOREQ = /\^=/
  JS_RSEQ = /\>=/
  JS_LSEQ = /\<=/
  JS_NEQ = /!=/
  JS_EQEQEQ = /===/
  JS_EQEQ = /==/
  JS_NEQEQ = /!==/
  JS_LSLS = /\<\</
  JS_RSRS = /\>\>/
  JS_ADDADD = /\+\+/
  JS_SUBSUB = /--/
  JS_ANDAND = /&&/
  JS_OROR = /\|\|/
  JS_RS = /\>/
  JS_LS = /\</
  JS_MUL = /\*/
  JS_DIV = /\//
  JS_MOD = /%/
  JS_ADD = /\+/
  JS_SUB = /-/
  JS_EQ = /=/
  JS_BNOT = /~/
  JS_NOT = /!/
  JS_BAND = /&/
  JS_BOR = /\|/
  JS_BXOR = /\^/
  JS_WITH = /\bwith(?![$\w])/
  JS_UNSIGNED = /\bunsigned(?![$\w])/
  JS_LONG = /\blong(?![$\w])/
  JS_INT = /\bint(?![$\w])/
  JS_SHORT = /\bshort(?![$\w])/
  JS_CHAR = /\bchar(?![$\w])/
  
  JS_LPAR = /\(/
  JS_RPAR = /\)/
  
  JS_ALPAR = /\[/
  JS_ARPAR = /\]/
  
  JS_MLPAR = /\{/
  JS_MRPAR = /\}/
  
  JS_COLON = /:/
  JS_SEMICOLON = /;/
  
  JS_COMMA = /,/
  JS_QUESTION = /\?/
  
  JS_DOT = /\./
  JS_DOTDOTDOT = /\.\.\./

  OBJJ_IMPLEMENTATION = /@implementation(?![$\w])/
  OBJJ_ACCESSORS = /@accessors(?![$\w])/
  OBJJ_CLASS = /@class(?![$\w])/
  OBJJ_END = /@end(?![$\w])/
  OBJJ_IMPORT = /@import(?![$\w])/
  OBJJ_SELECTOR = /@selector(?![$\w])/
  OBJJ_EACH = /@each(?![$\w])/

  def tokens()
    
    comment /\/\/.*\n?/
    comment /\/\*(?:.|\n)*?\*\/(?=.|$)/
    
    commentAmbiguity JS_REGEX
    commentAmbiguity JS_STRING_LITERAL
    commentAmbiguity /\/\/.*\n?/
    commentAmbiguity /\/\*(?:.|\n)*?\*\/(?=.|$)/
    commentAmbiguity /\//
    commentAmbiguity /(?:[^\/"']|[\r\n])*/
    
    token JS_NUMERIC_LITERAL
    
    token JS_COMMA, ","
    token JS_COLON, ":"
    token JS_SEMICOLON, ";"
    
    token JS_LPAR, "("
    token JS_RPAR, ")"
    
    token JS_MLPAR, "{"
    token JS_MRPAR, "}"
    
    token JS_ALPAR, "["
    token JS_ARPAR, "]"
    
    token JS_DOTDOTDOT, "..."
    token JS_DOT, "."
    
    token JS_REGEX
    token JS_STRING_LITERAL
    token JS_FUNCTION, "function"
    token JS_VAR, "var"
    token JS_CASE, "case"
    token JS_DEFAULT, "default"
    token JS_SWITCH, "switch"
    token JS_BREAK, "break"
    token JS_CONTINUE, "continue"
    token JS_INSTANCEOF, "instanceof"
    token JS_SUPER, "super"
    token JS_RETURN, "return"
    token JS_IF, "if"
    token JS_ELSE, "else"
    token JS_DO, "do"
    token JS_WHILE, "while"
    token JS_FOR, "for"
    token JS_TRY, "try"
    token JS_CATCH, "catch"
    token JS_FINALLY, "finally"
    token JS_THROW, "throw"
    token JS_NEW, "new"
    token JS_TYPEOF, "typeof"
    token JS_WITH, "with"
    token JS_IN, "in"
    token JS_DELETE, "delete"
    token JS_LONG, "long"
    token JS_INT, "int"
    token JS_CHAR, "char"
    token JS_SHORT, "short"
    token JS_UNSIGNED, "unsigned"
  
    token JS_IDENTIFIER
    
    token JS_EQEQEQ, "==="
    token JS_EQEQ, "=="
    token JS_EQ, "="
    
    token JS_ADDEQ, "+="
    token JS_ADDADD, "++"
    token JS_ADD, "+"
    token JS_SUBEQ, "-="
    token JS_SUBSUB, "--"
    token JS_SUB, "-"
    
    token JS_RSRSRSEQ, ">>>="
    token JS_RSRSRS, ">>>"
    token JS_LSLSEQ, "<<="
    token JS_RSRSEQ, ">>="
    token JS_MULEQ, "*="
    token JS_DIVEQ, "/="
    token JS_MODEQ, "%="
    token JS_BANDEQ, "&="
    token JS_BOREQ, "|="
    token JS_BXOREQ, "^="
    token JS_RSEQ, ">="
    token JS_LSEQ, "<="
    token JS_NEQEQ, "!=="
    token JS_NEQ, "!="
    token JS_LSLS, "<<"
    token JS_RSRS, ">>"
    token JS_ANDAND, "&&"
    token JS_OROR, "||"
    token JS_RS, ">"
    token JS_LS, "<"
    token JS_MUL, "*"
    token JS_DIV, "/"
    token JS_MOD, "%"
    token JS_BNOT, "~"
    token JS_NOT, "!"
    token JS_BAND, "&"
    token JS_BOR, "|"
    token JS_BXOR, "^"
    token JS_QUESTION, "?"
    
    
    token OBJJ_IMPLEMENTATION, "@implementation"
    token OBJJ_ACCESSORS, "@accessors"
    token OBJJ_CLASS, "@class"
    token OBJJ_END, "@end"
    token OBJJ_IMPORT_TAG_LITERAL
    token OBJJ_IMPORT, "@import"
    token OBJJ_SELECTOR, "@selector"
    token OBJJ_EACH, "@each"
  end

end