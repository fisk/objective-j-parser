#!ruby
# coding: utf-8
# 
# js_parser.rb
#
# Created by Erik Österlund on 1/14/10.
# Copyright 2010 Växjö Universitet. All rights reserved.
#

require 'table_generator'
require 'js_compiler_single'

module LALR
  
  class InterpreterGenerator
    
    def generate_parser_single
      sm = symbol_to_index
      token_to_num = {}
      @tokens.size.times do |i|
        token_to_num[@tokens[i]] = i + 1 # Start symbol is 0
      end
      
      result = <<-end.here_with_pipe
        |
        |ruleLength = [#{@rules.map{|rule|rule.productions.size.to_s}.join(",")}];
          |ruleSym = [#{@rules.map{|rule|sm[rule.name]}.join(",")}];
          |goto = [#{
            @gotos.size.times.map do |i|
              "{" + @gotos[i].each.map do |k, v|
                "#{sm[k]}:#{v}"
              end.join(",") + "}"
            end.join(",")
          }];
          |shift = [#{
            @actions.size.times.map do |i|
              "{" + @actions[i].select do |k, v|
                v.action == :shift
              end.map do |k, v|
                "#{k.is_a?(EOF) ? 0 : (k.is_a?(Epsilon) ? "e" : token_to_num[k])}:#{v.number}"
              end.join(",") + "}"
            end.join(",")
          }];
          |reduce = [#{
            @actions.size.times.map do |i|
              "{" + @actions[i].select do |k, v|
                v.action == :reduce
              end.map do |k, v|
                "#{k.is_a?(EOF) ? 0 : (k.is_a?(Epsilon) ? "e" : token_to_num[k])}:#{v.number}"
              end.join(",") + "}"
            end.join(",")
          }];
          |accept = {#{
            @actions.size.times.select do |i|
              @actions[i].select{|k, v| v.action == :accept}.size > 0
            end.map do |i|
              "#{i}:{" + @actions[i].select{|k, v| v.action == :accept}.map do |k, v|
                "#{k.is_a?(EOF) ? 0 : (k.is_a?(Epsilon) ? "e" : token_to_num[k])}:true"
              end.join(",") + "}"
            end.join(",")
          }};
        |
        |function #{@name}_parser()
        |{
        |}
          |#{@name}_parser.prototype.se = function(index)
          |{
            |throw index;
          |}
          |
          |#{@name}_parser.prototype.parse = function(tokens)
          |{
            |var index = 0;
            |tok = tokens[index++];
            |var symbol = null;
            |var o = [];
            |var s = [0];
            |var si = 0;
            |var temp;
            |var state = s[si];
            |while(true){
              |if (symbol != null)
              |{
                |state = s[++si] = goto[state][symbol];
                |symbol = null;
              |} else if(temp = shift[state][tok])
              |{
                |s[++si] = state = temp;tok = tokens[index++];
              |} else if(temp = reduce[state][tok]) {
                |o[o.length] = temp;
                |state = s[si -= ruleLength[temp]];
                |symbol = ruleSym[temp];
              |} else if(accept[state] && accept[state][tok]) {
                |o.push(0);
                |return o;
              |} else if(temp = shift[state]["e"]) {
                |s[++si] = state = temp;
              |} else {
                |if (index == 1)
                  |return o;
                |this.se(index);
                |return;
              |}
            |}
          |}
      end
      result + generate_compiler_single
    end
    
  end
  
end
