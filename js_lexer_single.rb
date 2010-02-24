#!ruby
# coding: utf-8
# 
# js_lexer.rb
#
# Created by Erik Österlund on 1/14/10.
# Copyright 2010 Växjö Universitet. All rights reserved.
#

require 'table_generator'

module LALR
  
  class InterpreterGenerator
    
    def generate_lexer_single
      token_to_num = {}
      @tokens.size.times do |i|
        token_to_num[@tokens[i]] = i + 1 # Start symbol is 0
      end
      
      <<-end.here_with_pipe
      |anyToken = #{"/" + @tokens[(0..(@tokens.length-1))].map{|to|to.source}.join("|") + "/mg"};
      |anyComment = /#{@commentAmbiguities.map{|c|"(" + c.source + ")"}.join("|")}/mg;
      |tokenLit = {#{@token_lit.each.map{|k,v|
        "\"" + k.to_s + "\":" + v.to_s
      }.join(",")}};
      |function #{@name}_lexer(str)
      |{
        |this._tokens = null;
        |this._numbers = [];
        |this._code = str;
      |}
      |#{@name}_lexer.prototype.removeComments = function()
      |{
        |var mat = this._code.match(anyComment);
        |for (var i = 0; i < mat.length; i++)
        |{
          |var tmp = mat[i];
          |var first = tmp.charAt(0);
          |var second = tmp.charAt(1);
          |if(first === "/" && (second === "/" || second === "*")){
            |mat[i] = "";
          |}
        |}
        |this._code = mat.join("");
      |}
      |#{@name}_lexer.prototype.matches = function()
      |{
        |this.removeComments();
        |this._tokens = this._code.match(anyToken);
        |if (this._tokens === null)this._tokens = [];
        |return this._tokens;
      |}
      |#{@name}_lexer.prototype.tokens = function()
      |{
        |var tol = this._tokens.length;
        |var fs;
        |var fs2;
        |for (var j = 0; j < tol; j++)
        |{
          |var tok = this._tokens[j];
          |var pm;
          |if ((pm = tokenLit[tok]) === undefined) {
            |if (/\\d/.test(fs = tok.charAt(0))){
              |this._numbers.push(#{token_to_num[fix_regex(JS_NUMERIC_LITERAL)]});
            |} else if (fs === '"' || fs === "'" || (fs2 = tok.charAt(1)) === '"' || fs2 === "'"){
              |this._numbers.push(#{token_to_num[fix_regex(JS_STRING_LITERAL)]});
            |} else if (fs === '/'){
              |this._numbers.push(#{token_to_num[fix_regex(JS_REGEX)]});
            |} else if (fs === '@'){
              |this._numbers.push(#{token_to_num[fix_regex(OBJJ_IMPORT_TAG_LITERAL)]});
            |} else {
              |this._numbers.push(#{token_to_num[fix_regex(JS_IDENTIFIER)]});
            |}
          |} else if (typeof(pm) !== "number") {this._numbers.push(#{token_to_num[fix_regex(JS_IDENTIFIER)]});}
          |else {this._numbers.push(pm);}
        |}
        |this._numbers.push(0);
        |return this._numbers;
      |}
      end
    end
    
  end
  
end
