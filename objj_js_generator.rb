#!ruby
# coding: utf-8
# 
# objj_js_generator.rb
#
# Created by Erik Österlund on 1/14/10.
# Copyright 2010 Växjö Universitet. All rights reserved.
#

require 'js_interpreter_generator'
require 'objj_js_generator_additions'
require 'objj_js_generator_tokens'
include LALR


class ObjjJsGenerator < InterpreterGenerator

  def initialize()
    super("objj", "objj_js")
    tokens
    rules
  end

  def rules()

start(:JS_PROGRAM)

rule(:JS_PROGRAM => [:JS_ELEMENTS]) {'@1.e();'}


rule(:JS_ELEMENTS => [:JS_ELEMENT]) {'@1.e();'}
rule(:JS_ELEMENTS => [Epsilon.instance]) {''}
rule(:JS_ELEMENTS => [:JS_ELEMENTS, :JS_ELEMENT]) {'@1.e();@2.e();'}


rule(:JS_ELEMENT => [:JS_STATEMENT]) {'@1.e();'}
rule(:JS_ELEMENT => [:JS_FUNC_DECL]) {'@1.e();'}


rule(:JS_FUNC_DECL => [JS_FUNCTION, JS_IDENTIFIER, JS_LPAR, :JS_FUNC_PARAMS, JS_RPAR, :JS_FUNC_BODY]) {
  '$.push($2);
  $.push(" = function(");
  @4.e();
  $.push(")");
  @6.e();
  $.push(";");'
}
rule(:JS_FUNC_DECL => [:JS_LHS_EXPR, JS_EQ, :JS_FUNC_EXPR]) {
  '@1.e();$.push("=");@3.e();
  $.push(";");'
}

rule(:JS_FUNC_EXPR => [JS_FUNCTION, JS_IDENTIFIER, JS_LPAR, :JS_FUNC_PARAMS, JS_RPAR, :JS_FUNC_BODY]) {
  '$.push($2);
  $.push(" = function(");
  @4.e();
  $.push(")");
  @6.e();'
}
rule(:JS_FUNC_EXPR => [JS_FUNCTION, JS_LPAR, :JS_FUNC_PARAMS, JS_RPAR, :JS_FUNC_BODY]) {
  '$.push("function(");
  @3.e();
  $.push(")");
  @5.e();'
}


rule(:JS_FUNC_PARAMS => [:JS_REST]) {'@1.e();'}
rule(:JS_FUNC_PARAMS => [Epsilon.instance]) {''}
rule(:JS_FUNC_PARAMS => [:JS_PARAM_LIST]) {'@1.e();'}
rule(:JS_FUNC_PARAMS => [:JS_PARAM_LIST, JS_COMMA, :JS_REST]) {
  '@1.e();$.push(",");@3.e();'
}


rule(:JS_PARAM_LIST => [:JS_PARAM]) {'@1.e();'}
rule(:JS_PARAM_LIST => [:JS_PARAM_LIST, JS_COMMA, :JS_PARAM]) {
  '@1.e();$.push(",");@3.e();'
}

rule(:JS_PARAM => [JS_IDENTIFIER, :JS_PARAM_INITIALIZER]) {'$.push($1);@2.e();'}

rule(:JS_PARAM_INITIALIZER => [JS_EQ, :JS_COND_EXPR]) {'$.push("=");@2.e();'}
rule(:JS_PARAM_INITIALIZER => [Epsilon.instance]) {''}

rule(:JS_FUNC_BODY => [JS_MLPAR, :JS_ELEMENTS, JS_MRPAR]) {
  '$.push("{");@2.e();$.push("}");'
}

rule(:JS_STATEMENT => [:JS_VAR_STATEMENT]) {'@1.e();'}
rule(:JS_STATEMENT => [:JS_BLOCK]) {'@1.e();'}
rule(:JS_STATEMENT => [:JS_EMPTY_STATEMENT]) {'@1.e();'}
rule(:JS_STATEMENT => [:JS_EXPR_STATEMENT]) {'@1.e();'}
rule(:JS_STATEMENT => [:JS_IF_STATEMENT]) {'@1.e();'}
rule(:JS_STATEMENT => [:JS_ITER_STATEMENT]) {'@1.e();'}
rule(:JS_STATEMENT => [:JS_CONT_STATEMENT]) {'@1.e();'}
rule(:JS_STATEMENT => [:JS_BREAK_STATEMENT]) {'@1.e();'}
rule(:JS_STATEMENT => [:JS_RETURN_STATEMENT]) {'@1.e();'}
rule(:JS_STATEMENT => [:JS_SWITCH_STATEMENT]) {'@1.e();'}
rule(:JS_STATEMENT => [:JS_THROW_STATEMENT]) {'@1.e();'}
rule(:JS_STATEMENT => [:JS_TRY_STATEMENT]) {'@1.e();'}
rule(:JS_STATEMENT => [:JS_WITH_STATEMENT]) {'@1.e();'}

rule(:JS_BLOCK => [JS_MLPAR, :JS_ELEMENTS, JS_MRPAR]) {
  '$.push("{");@2.e();$.push("}");'
}
rule(:JS_BLOCK => [JS_MLPAR, JS_MRPAR]) {
  '$.push("{}");'
}

rule(:JS_SEPARATOR => Epsilon.instance){''}
rule(:JS_SEPARATOR => JS_SEMICOLON){'$.push(";");'}

rule(:JS_STATEMENT_LIST => [:JS_STATEMENT]) {'@1.e();'}
rule(:JS_STATEMENT_LIST => [:JS_STATEMENT_LIST, :JS_STATEMENT]) {'@1.e();@2.e();'}


rule(:JS_VAR_STATEMENT => [JS_VAR, :JS_VAR_DECL_LIST, :JS_SEPARATOR]) {
  '$.push("var ");@2.e();$.push(";");'
}


rule(:JS_VAR_DECL_LIST => [:JS_VAR_DECL]) {'@1.e();'}
rule(:JS_VAR_DECL_LIST => [:JS_VAR_DECL_LIST, JS_COMMA, :JS_VAR_DECL]) {
 '@1.e();$.push(",");@3.e();'
}

rule(:JS_VAR_DECL => [JS_IDENTIFIER, :JS_INITIALIZER]) {
  '$.push($1);@2.e();'
}


rule(:JS_INITIALIZER => [JS_EQ, :JS_ASSIGN_EXPR]) {'$.push("=");@2.e();'}
rule(:JS_INITIALIZER => [Epsilon.instance]) {''}


rule(:JS_EMPTY_STATEMENT => [JS_SEMICOLON]) {'$.push(";");'}


rule(:JS_EXPR_STATEMENT => [:JS_EXPR, :JS_SEPARATOR]) {'@1.e();$.push(";");'}


rule(:JS_WITH_STATEMENT => [JS_WITH, JS_LPAR, :JS_EXPR, JS_RPAR, :JS_STATEMENT]) {
  '$.push("with(");@3.e();$.push(")");@5.e();'
}

rule(:JS_IF_STATEMENT => [JS_IF, JS_LPAR, :JS_ASSIGN_EXPR, JS_RPAR, :JS_STATEMENT, JS_ELSE, :JS_STATEMENT]) {
  '$.push("if(");
  @3.e();
  $.push(")");
  @5.e();
  $.push(" else ");
  @7.e();'
}
rule(:JS_IF_STATEMENT => [JS_IF, JS_LPAR, :JS_ASSIGN_EXPR, JS_RPAR, :JS_STATEMENT]) {
  '$.push("if(");
  @3.e();
  $.push(")");
  @5.e();'
}


rule(:JS_ITER_STATEMENT => [JS_DO, :JS_STATEMENT, JS_WHILE, JS_LPAR, :JS_EXPR, JS_RPAR, :JS_SEPARATOR]) {
  '$.push("do");
  @2.e();
  $.push("while(");
  @5.e();
  $.push(");");'
}
rule(:JS_ITER_STATEMENT => [JS_WHILE, JS_LPAR, :JS_EXPR, JS_RPAR, :JS_STATEMENT]) {
  '$.push("while(");
  @3.e();
  $.push(")");
  @5.e();'
}


rule(:JS_ITER_STATEMENT => [JS_FOR, JS_LPAR, :JS_FOR_INIT, JS_SEMICOLON, :JS_FOR_PARAM, JS_SEMICOLON, :JS_FOR_PARAM, JS_RPAR, :JS_STATEMENT]) {
  '$.push("for(");
  @3.e();
  $.push(";");
  @5.e();
  $.push(";");
  @7.e();
  $.push(")");
  @9.e();'
}
rule(:JS_ITER_STATEMENT => [JS_FOR, JS_LPAR, JS_IDENTIFIER, JS_IN, :JS_EXPR, JS_RPAR, :JS_STATEMENT]) {
  '$.push("for(");
  $.push($3);
  $.push(" in ");
  @5.e();
  $.push(")");
  @7.e();'
}
rule(:JS_ITER_STATEMENT => [JS_FOR, JS_LPAR, JS_VAR, JS_IDENTIFIER, JS_IN, :JS_EXPR, JS_RPAR, :JS_STATEMENT]) {
  '$.push("for(var ");
  $.push($4);
  $.push(" in ");
  @6.e();
  $.push(")");
  @8.e();'
}

rule(:JS_FOR_PARAM => [:JS_EXPR]) {'@1.e();'}
rule(:JS_FOR_PARAM => [Epsilon.instance]) {''}
rule(:JS_FOR_INIT => [:JS_FOR_PARAM]) {'@1.e();'}
rule(:JS_FOR_INIT => [JS_VAR, :JS_VAR_DECL_LIST]) {'$.push("var ");@2.e();'}

rule(:JS_CONT_STATEMENT => [JS_CONTINUE, :JS_SEPARATOR]) {'$.push("continue;");'}


rule(:JS_BREAK_STATEMENT => [JS_BREAK, :JS_SEPARATOR]) {'$.push("break;");'}


rule(:JS_RETURN_STATEMENT => [JS_RETURN, :JS_SEPARATOR]) {'$.push("return;");'}
rule(:JS_RETURN_STATEMENT => [JS_RETURN, :JS_EXPR, :JS_SEPARATOR]) {
  '$.push("return ");
  @2.e();
  $.push(";");'
}

rule(:JS_SWITCH_STATEMENT => [JS_SWITCH, JS_LPAR, :JS_EXPR, JS_RPAR, :JS_CASE_BLOCK]) {
  '$.push("switch(");
  @3.e();
  $.push(")");
  @5.e();'
}

rule(:JS_CASE_BLOCK => [JS_MLPAR, :JS_CASE_CLAUSES, :JS_CASE_DEFAULT, :JS_CASE_CLAUSES, JS_MRPAR]) {
  '$.push("{");
  @2.e();
  @3.e();
  @4.e();
  $.push("}");'
}


rule(:JS_CASE_CLAUSES => [:JS_CASE_CLAUSE]) {'@1.e();'}
rule(:JS_CASE_CLAUSES => [:JS_CASE_CLAUSES, :JS_CASE_CLAUSE]) {'@1.e();@2.e();'}


rule(:JS_CASE_CLAUSE => [JS_CASE, :JS_EXPR, JS_COLON]) {
  '$.push("case ");
  @2.e();
  $.push(":");'
}
rule(:JS_CASE_CLAUSE => [JS_CASE, :JS_EXPR, JS_COLON, :JS_STATEMENT_LIST]) {
  '$.push("case ");
  @2.e();
  $.push(":");
  @4.e();'
}
rule(:JS_CASE_CLAUSE => [Epsilon.instance]) {''}


rule(:JS_CASE_DEFAULT => [JS_DEFAULT, JS_COLON]) {'$.push("default:");'}
rule(:JS_CASE_DEFAULT => [Epsilon.instance]) {''}
rule(:JS_CASE_DEFAULT => [JS_DEFAULT, JS_COLON, :JS_STATEMENT_LIST]) {'$.push("default:");@3.e();'}


rule(:JS_THROW_STATEMENT => [JS_THROW, :JS_EXPR, :JS_SEPARATOR]) {
  '$.push("throw ");
  @2.e();
  $.push(";");'
}


rule(:JS_TRY_STATEMENT => [JS_TRY, :JS_BLOCK, :JS_CATCH_CLAUSE, :JS_FINALLY_CLAUSE]) {
  '$.push("try");
  @2.e();
  @3.e();
  @4.e();'
}

rule(:JS_CATCH_CLAUSE => [JS_CATCH, JS_LPAR, JS_IDENTIFIER, JS_RPAR, :JS_BLOCK]) {
  '$.push("catch(");
  @3.e();
  $.push(")");
  @5.e();'
}
rule(:JS_CATCH_CLAUSE => [Epsilon.instance]) {''}

rule(:JS_FINALLY_CLAUSE => [JS_FINALLY, :JS_BLOCK]) {'$.push("finally");@2.e();'}
rule(:JS_FINALLY_CLAUSE => [Epsilon.instance]) {''}


rule(:JS_PRIMARY_EXPR => [JS_IDENTIFIER]) {'$.push($1);'}
rule(:JS_PRIMARY_EXPR => [JS_STRING_LITERAL]) {
  '$.push(($1.charAt(0) === "@") ? $1.slice(1) : $1);'
}
rule(:JS_PRIMARY_EXPR => [JS_NUMERIC_LITERAL]) {'$.push($1);'}
rule(:JS_PRIMARY_EXPR => [JS_REGEX]) {'$.push($1);'}
rule(:JS_PRIMARY_EXPR => [:JS_ARRAY_LITERAL]) {'@1.e();'}
rule(:JS_PRIMARY_EXPR => [:JS_OBJECT_LITERAL]) {'@1.e();'}
rule(:JS_PRIMARY_EXPR => [JS_LPAR, :JS_ASSIGN_EXPR, JS_RPAR]) {
  '$.push("(");
  @2.e();
  $.push(")");'
}


rule(:JS_ARRAY_LITERAL => [JS_ALPAR, JS_ARPAR]) {'$.push("[]");'}
rule(:JS_ARRAY_LITERAL => [JS_ALPAR, :JS_ELEMENT_LIST, JS_ARPAR]) {
  '$.push("[");
  @2.e();
  $.push("]");'
}


rule(:JS_ELEMENT_LIST => [:JS_ASSIGN_EXPR]) {'@1.e();'}
rule(:JS_ELEMENT_LIST => [:JS_ELEMENT_LIST, JS_COMMA, :JS_ASSIGN_EXPR]) {
  '@1.e();
  $.push(",");
  @3.e();'
}


rule(:JS_OBJECT_LITERAL => [JS_MLPAR, JS_MRPAR]) {'$.push("{}");'}
rule(:JS_OBJECT_LITERAL => [JS_MLPAR, :JS_PROP_LIST, JS_MRPAR]) {
  '$.push("{");
  @2.e();
  $.push("}");'
}


rule(:JS_PROP_LIST => [:JS_PROP_NAME, JS_COLON, :JS_ASSIGN_EXPR]) {
  '@1.e();
  $.push(":");
  @3.e();'
}
rule(:JS_PROP_LIST => [:JS_PROP_LIST, JS_COMMA, :JS_PROP_NAME, JS_COLON, :JS_ASSIGN_EXPR]) {
  '@1.e();
  $.push(",");
  @3.e();
  $.push(":");
  @5.e();'
}


rule(:JS_PROP_NAME => [JS_IDENTIFIER]) {'$.push($1);'}
rule(:JS_PROP_NAME => [JS_STRING_LITERAL]) {'$.push(($1.charAt(0) === "@") ? $1.slice(1) : $1);'}
rule(:JS_PROP_NAME => [JS_NUMERIC_LITERAL]) {'$.push($1);'}


rule(:JS_MEMBER_EXPR => [:JS_PRIMARY_EXPR]) {'@1.e();'}
rule(:JS_MEMBER_EXPR => [:JS_FUNC_EXPR]) {'@1.e();'}
rule(:JS_MEMBER_EXPR => [:JS_MEMBER_EXPR, :JS_PROPERTY_SUFFIX]) {'@1.e();@2.e();'}
rule(:JS_MEMBER_EXPR => [JS_NEW, :JS_MEMBER_EXPR, :JS_ARGS]) {'$.push("new ");@2.e();@3.e();'}


rule(:JS_NEW_EXPR => [:JS_MEMBER_EXPR]) {'@1.e();'}
rule(:JS_NEW_EXPR => [JS_NEW, :JS_MEMBER_EXPR]) {'$.push("new ");@2.e();'}


rule(:JS_CALL_EXPR => [:JS_MEMBER_EXPR, :JS_ARGS]) {'@1.e();@2.e();'}
rule(:JS_CALL_EXPR => [:JS_CALL_EXPR, :JS_ARGS]) {'@1.e();@2.e();'}
rule(:JS_CALL_EXPR => [:JS_CALL_EXPR, :JS_PROPERTY_SUFFIX]) {'@1.e();@2.e();'}


rule(:JS_PROPERTY_SUFFIX => [JS_DOT, JS_IDENTIFIER]) {'$.push(".");$.push($2);'}
rule(:JS_PROPERTY_SUFFIX => [JS_ALPAR, :JS_ASSIGN_EXPR, JS_ARPAR]) {
  '$.push("[");
   @2.e();
   $.push("]");'
}


rule(:JS_ARGS => [JS_LPAR, JS_RPAR]) {'$.push("()");'}
rule(:JS_ARGS => [JS_LPAR, :JS_ARG_LIST, JS_RPAR]) {
  '$.push("(");
  @2.e();
  $.push(")");'
}


rule(:JS_ARG_LIST => [:JS_ASSIGN_EXPR]) {'@1.e();'}
rule(:JS_ARG_LIST => [:JS_ARG_LIST, JS_COMMA, :JS_ASSIGN_EXPR]) {'@1.e();$.push(",");@3.e();'}


rule(:JS_LHS_EXPR => [:JS_NEW_EXPR]) {'@1.e();'}
rule(:JS_LHS_EXPR => [:JS_CALL_EXPR]) {'@1.e();'}


rule(:JS_UNARY_EXPR => [:JS_POSTFIX_EXPR]) {'@1.e();'}
rule(:JS_UNARY_EXPR => [JS_TYPEOF, :JS_UNARY_EXPR]) {'$.push("typeof ");@2.e();'}
rule(:JS_UNARY_EXPR => [JS_DELETE, :JS_UNARY_EXPR]) {'$.push("delete ");@2.e();'}


rule(:JS_NUM_EXPR => [:JS_UNARY_EXPR]) {'@1.e();'}
rule(:JS_NUM_EXPR => [:JS_NUM_EXPR, :JS_NUM_OP, :JS_UNARY_EXPR]) {'@1.e();@2.e();@3.e();'}


rule(:JS_NUM_OP => [JS_RSRSRS]) {'$.push(">>>");'}
rule(:JS_NUM_OP => [JS_LSLS]) {'$.push("<<");'}
rule(:JS_NUM_OP => [JS_RSRS]) {'$.push(">>");'}
rule(:JS_NUM_OP => [JS_MUL]) {'$.push("*");'}
rule(:JS_NUM_OP => [JS_DIV]) {'$.push("/");'}
rule(:JS_NUM_OP => [JS_MOD]) {'$.push("%");'}
rule(:JS_NUM_OP => [JS_ADD]) {'$.push("+");'}
rule(:JS_NUM_OP => [JS_SUB]) {'$.push("-");'}


rule(:JS_REL_EXPR => [:JS_NUM_EXPR]) {'@1.e();'}
rule(:JS_REL_EXPR => [:JS_REL_EXPR, :JS_REL_OP, :JS_NUM_EXPR]) {'@1.e();@2.e();@3.e();'}


rule(:JS_REL_OP => [JS_RSEQ]) {'$.push(">=");'}
rule(:JS_REL_OP => [JS_LSEQ]) {'$.push("<=");'}
rule(:JS_REL_OP => [JS_NEQ]) {'$.push("!=");'}
rule(:JS_REL_OP => [JS_EQEQEQ]) {'$.push("===");'}
rule(:JS_REL_OP => [JS_EQEQ]) {'$.push("==");'}
rule(:JS_REL_OP => [JS_NEQEQ]) {'$.push("!==");'}
rule(:JS_REL_OP => [JS_INSTANCEOF]) {'$.push(" instanceof ");'}
rule(:JS_REL_OP => [JS_RS]) {'$.push(">");'}
rule(:JS_REL_OP => [JS_LS]) {'$.push("<");'}


rule(:JS_POSTFIX_EXPR => [:JS_LHS_EXPR, JS_ADDADD]) {'@1.e();$.push($2);'}
rule(:JS_POSTFIX_EXPR => [:JS_LHS_EXPR, JS_SUBSUB]) {'@1.e();$.push($2);'}
rule(:JS_POSTFIX_EXPR => [:JS_LHS_EXPR]) {'@1.e();'}


rule(:JS_UNARY_EXPR => [JS_ADDADD, :JS_POSTFIX_EXPR]) {'$.push("++");@2.e();'}
rule(:JS_UNARY_EXPR => [JS_SUBSUB, :JS_POSTFIX_EXPR]) {'$.push("--");@2.e();'}
rule(:JS_UNARY_EXPR => [JS_ADD, :JS_POSTFIX_EXPR]) {'$.push("+");@2.e();'}
rule(:JS_UNARY_EXPR => [JS_SUB, :JS_POSTFIX_EXPR]) {'$.push("-");@2.e();'}
rule(:JS_UNARY_EXPR => [JS_BNOT, :JS_UNARY_EXPR]) {'$.push("~");@2.e();'}
rule(:JS_UNARY_EXPR => [JS_NOT, :JS_UNARY_EXPR]) {'$.push("!");@2.e();'}


rule(:JS_UNARY_EXPR => :JS_IN_EXPR){
  '@1.e();'
}


rule(:JS_BITWISE_EXPR => [:JS_REL_EXPR]) {'@1.e();'}
rule(:JS_BITWISE_EXPR => [:JS_BITWISE_EXPR, :JS_BITWISE_OP, :JS_REL_EXPR]) {'@1.e();@2.e();@3.e();'}


rule(:JS_BITWISE_OP => [JS_BAND]) {'$.push($1);'}
rule(:JS_BITWISE_OP => [JS_BOR]) {'$.push($1);'}
rule(:JS_BITWISE_OP => [JS_BXOR]) {'$.push($1);'}


rule(:JS_LOGICAL_EXPR => [:JS_BITWISE_EXPR]) {'@1.e();'}
rule(:JS_LOGICAL_EXPR => [:JS_LOGICAL_EXPR, :JS_LOGICAL_OP, :JS_BITWISE_EXPR]) {'@1.e();@2.e();@3.e();'}


rule(:JS_LOGICAL_OP => [JS_ANDAND]) {'$.push("&&");'}
rule(:JS_LOGICAL_OP => [JS_OROR]) {'$.push("||");'}


rule(:JS_COND_EXPR => [:JS_LOGICAL_EXPR]) {'@1.e();'}
rule(:JS_COND_EXPR => [:JS_LOGICAL_EXPR, JS_QUESTION, :JS_ASSIGN_EXPR, JS_COLON, :JS_ASSIGN_EXPR]) {'@1.e();$.push($2);@3.e();@4.e();@5.e();'}


rule(:JS_ASSIGN_EXPR => [:JS_COND_EXPR]) {'@1.e();'}
rule(:JS_ASSIGN_EXPR => [:JS_LHS_EXPR, :JS_ASSIGN_OP, :JS_ASSIGN_EXPR]) {'@1.e();@2.e();@3.e();'}

rule(:JS_IN_EXPR => [:JS_LHS_EXPR, JS_IN, :JS_LHS_EXPR]){
  '@1.e();$.join(" in ");@3.e();'
}

rule(:JS_ASSIGN_OP => [JS_EQ]) {'$.push("=");'}
rule(:JS_ASSIGN_OP => [JS_LSLSEQ]) {'$.push("<<=");'}
rule(:JS_ASSIGN_OP => [JS_RSRSEQ]) {'$.push(">>=");'}
rule(:JS_ASSIGN_OP => [JS_RSRSRSEQ]) {'$.push(">>>=");'}
rule(:JS_ASSIGN_OP => [JS_MULEQ]) {'$.push("*=");'}
rule(:JS_ASSIGN_OP => [JS_DIVEQ]) {'$.push("/=");'}
rule(:JS_ASSIGN_OP => [JS_MODEQ]) {'$.push("%=");'}
rule(:JS_ASSIGN_OP => [JS_ADDEQ]) {'$.push("+=");'}
rule(:JS_ASSIGN_OP => [JS_SUBEQ]) {'$.push("-=");'}
rule(:JS_ASSIGN_OP => [JS_BANDEQ]) {'$.push("&=");'}
rule(:JS_ASSIGN_OP => [JS_BOREQ]) {'$.push("|=");'}
rule(:JS_ASSIGN_OP => [JS_BXOREQ]) {'$.push("^=");'}


rule(:JS_EXPR => [:JS_ASSIGN_EXPR]) {'@1.e();'}
rule(:JS_EXPR => [:JS_EXPR, JS_COMMA, :JS_ASSIGN_EXPR]) {'@1.e();$.push(",");@3.e();'}


rule(:JS_REST => [JS_DOTDOTDOT, JS_IDENTIFIER]) {''}
rule(:JS_REST => [JS_DOTDOTDOT]) {''}
    
    additional_rules
  end

end

ObjjJsGenerator.new.generate_interpreter