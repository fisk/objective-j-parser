#!ruby
# coding: utf-8
# 
# js_compiler.rb
#
# Created by Erik Österlund on 1/14/10.
# Copyright 2010 Växjö Universitet. All rights reserved.
#

require 'table_generator'

module LALR
  
  class InterpreterGenerator
    
    def generate_compiler
      <<-end.here_with_pipe
        |function compile(){
          |var di = o.length;
          |var ti = t.length;
          |#{@compiler}
          |function N(){
            |this.$ = [];
          |}
          |N.prototype.e = function(){$.push(this.$[0]);};
          |var R = [#{
            @rules.size.times.map do |i|
              rule = @rules[i]
              prods = rule.productions
              
              str = "function N#{i}(){"
              str << "this.$ = [];"
              if i == 0
                str << "n = new R[o[--di]];"
                str << "this.e = function(){this.$[0].e();};"
                str << "this.$.push(n);"
              else
                prods.size.times.reverse_each do |p|
                  product = prods[p]
                  str << "var n;"
                  case product
                    when Symbol
                      str << "n = new R[o[--di]];"
                      str << "this.$.unshift(n);"
                    else
                      str << "n = new N();"
                      str << "n.$.push(t[--ti]);"
                      str << "this.$.unshift(n);"
                  end
                end
              end
              str << "}"
              str
            end.join(",")
          }];
          |#{
            (1...@rules.size).each.map do |i|
              evaluator = @rule_evaluators[@rules[i]]
              "R[#{i}].prototype.e = function(){#{evaluator}};"
            end.join("")
          }
          |var $ = [];
          |#{@compiler_name ? "var context = new #{@compiler_name}();" : ""}
          |new R[0]().e();
          |postMessage($.join(""));
        |}
      end
      
    end
    
  end
  
end
