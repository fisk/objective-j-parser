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
    
    def generate_lexer
      <<-end.here_with_pipe
      |t = [/$/mg,#{@tokens.map{|t|"/" + t.source + "/gm"}.join(",")}];
      |var anyToken = #{"/" + @tokens[(0..(@tokens.length-1))].map{|to|to.source}.join("|") + "/mg"};
      |var tokens = null;
      |var numbers = [];
      |var comments = [#{@comments.map{|c|"/" + c.source + "/mg"}.join(",")}];
      |onmessage = function(message){
        |var str = message.data;
        |for(var k = 0; k < comments.length; k++){
          |comments[k].test("");
          |if(comments[k].test(str))
            |str = str.split(comments[k]).join("");
        |}
        |tokens = str.match(anyToken);
        |postMessage(JSON.stringify(tokens));
        |var start = new Date().getTime();
        |var now;
        |for (var j = 0; j < tokens.length; j++)
        |{
          |if ((now = new Date().getTime()) - start > 50)
          |{
            |start = now;
            |postMessage(JSON.stringify(numbers));
            |numbers = [];
          |}
          |var tok = tokens[j];
          |for(var i = 1; i < t.length; i++)
          |{
            |t[i].test("");
            |if(t[i].test(tok)){numbers.push(i);break;}
          |}
        |}
        |numbers.push(0);
        |postMessage(JSON.stringify(numbers));
        |return;
      |}
      end
    end
    
  end
  
end
