#!ruby
# coding: utf-8
# 
# js_parser.rb
#
# Created by Erik Österlund on 1/14/10.
# Copyright 2010 Växjö Universitet. All rights reserved.
#

require 'table_generator'

module LALR
  
  class InterpreterGenerator
    
    def generate_parser
      sm = symbol_to_index
      token_to_num = {}
      @tokens.size.times do |i|
        token_to_num[@tokens[i]] = i + 1 # Start symbol is 0
      end
      
      result = <<-end.here_with_pipe
        |var index = 0;
        |var jndex = 0;
        |var tok;
        |var numbers = [];
        |var tokens = null;
        |var t = null;
        |var o = [];
        |var s = [0];
        |var ruleLength = [#{@rules.map{|rule|rule.productions.size.to_s}.join(",")}];
        |var ruleSym = [#{@rules.map{|rule|sm[rule.name]}.join(",")}];
        |var goto = [#{
          @gotos.size.times.map do |i|
            "{" + @gotos[i].each.map do |k, v|
              "#{sm[k]}:#{v}"
            end.join(",") + "}"
          end.join(",")
        }];
        |var shift = [#{
          @actions.size.times.map do |i|
            "{" + @actions[i].select do |k, v|
              v.action == :shift
            end.map do |k, v|
              "#{k.is_a?(EOF) ? 0 : token_to_num[k]}:#{v.number}"
            end.join(",") + "}"
          end.join(",")
        }];
        |var reduce = [#{
          @actions.size.times.map do |i|
            "{" + @actions[i].select do |k, v|
              v.action == :reduce
            end.map do |k, v|
              "#{k.is_a?(EOF) ? 0 : token_to_num[k]}:#{v.number}"
            end.join(",") + "}"
          end.join(",")
        }];
        |var accept = {#{
          @actions.size.times.select do |i|
            @actions[i].select{|k, v| v.action == :accept}.size > 0
          end.map do |i|
            "#{i}:{" + @actions[i].select{|k, v| v.action == :accept}.map do |k, v|
              "#{k.is_a?(EOF) ? 0 : token_to_num[k]}:true"
             end.join(",") + "}"
          end.join(",")
        }};
        |function u()
        |{
          |if(index == tokens.length)
          |{
            |index = 0;
            |if(++jndex == numbers.length){tokens = null;return false;}
            |tokens = numbers[jndex];
          |}
          |tok = tokens[index++];
          |return true;
        |}
        |function se()
        |{
          |postMessage('Unexpected: "' + t[index-1] + '"');
          |return;
        |}
        |onmessage = function(message)
        |{
          |var data = JSON.parse(message.data);
          |if(t == null)
          |{
            |t = data;
            |return;
          |}
          |numbers.push(data);
          |if (tokens == null)
          |{
            |tokens = data;
            |index = 0;
          |} else
            |return;
          |derive();
        |}
        |
        |function derive()
        |{
          |if(!u()){return;};
          |var symbol = null;
          |while(true){
            |var state = s[s.length-1];
            |var temp;
            |if (symbol != null)
            |{
              |s.push(goto[state][symbol]);
              |symbol = null;
            |} else if(temp = shift[state][tok])
            |{
              |s.push(temp);if(!u()){return;};
            |} else if(temp = reduce[state][tok]) {
              |o.push(temp);
              |s = s.slice(0, s.length - ruleLength[temp]);
              |symbol = ruleSym[temp];
            |} else if(accept[state] && accept[state][tok]) {
              |tokens = null;
              |o.push(0);
              |compile();
              |return;
            |} else {se();return;}
          |}
        |}
      end
      result += generate_compiler
      result
    end
    
  end
  
end
