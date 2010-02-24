#!ruby
# coding: utf-8
# 
# js_compiler.rb
#
# Created by Erik Österlund on 1/14/10.
# Copyright 2010 Växjö Universitet. All rights reserved.
#

require 'table_generator'
require 'set'

module LALR
  
  class InterpreterGenerator
    
    def generate_compiler_single
      token_to_num = {}
      @tokens.size.times do |i|
        token_to_num[@tokens[i]] = i + 1 # Start symbol is 0
      end
      known_token_set = Set.new
      @token_lit.each do |str, num|
        known_token_set << num
      end
      
      <<-end.here_with_pipe
        |
        |#{@name}_parser.prototype.compile = function(t, o){
          |var di = o.length;
          |var ti = t.length;
          |#{@compiler}
          |function N(){
            |this.$0=t[--ti];
          |}
          |N.prototype.e = function(){$.push(this.$0);};
          |var R = [#{
            @rules.size.times.map do |i|
              rule = @rules[i]
              prods = rule.productions
              
              str = "function N#{i}(){"
              if i == 0
                str << "n = new R[o[--di]];"
                str << "this.e = function(){this.$1.e();};"
                str << "this.$1=n;"
              else
                prods.size.times.reverse_each do |p|
                  product = prods[p]
                  case product
                    when Symbol
                      str << "this.$#{p+1}=new R[o[--di]];"
                    when Regexp
                      if not known_token_set.include? token_to_num[p]
                        str << "this.$#{p+1}=new N();"
                      else
                        str << "ti--;"
                      end
                  end
                end
              end
              str << "}"
              str
            end.join(",")
          }];
          |#{
            (1...@rules.size).each.map do |i|
              evaluator = @rule_evaluators[i-1]
              "R[#{i}].prototype.e = function(){#{evaluator}};"
            end.join("")
          }
          |var $ = [];
          |#{@compiler_name ? "var context = new #{@compiler_name}();" : ""}
          |var start = new Date().getTime();
          |var tree = new R[0]();
          |console.log("Constructing tree: " + (new Date().getTime() - start));
          |var start = new Date().getTime();
          |tree.e();
          |console.log("Evaluating tree: " + (new Date().getTime() - start));
          |return [$.join(""), context._dependencies];
        |}
      end
      
    end
    
  end
  
end
