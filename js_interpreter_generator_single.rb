#!ruby
# coding: utf-8
# 
# js_interpreter_generator.rb
#
# Created by Erik Österlund on 1/14/10.
# Copyright 2010 Växjö Universitet. All rights reserved.
#

require 'table_generator'
require 'parser'
require 'set'
require 'digest'
require 'js_compiler_single'
require 'js_parser_single'
require 'js_lexer_single'

class String
  def here_with_pipe
    lines = self.split("\n")
    lines.map! {|c| c.sub!(/\s*\|/, '')}
    new_string = lines.join("\n")
    self.replace(new_string)
  end
end

module LALR
  
  class InterpreterGenerator
    
    def generate_interface_single
      result = <<-end.here_with_pipe
        |#{@header.gsub(/\n\s*/, "")}
        |function #{@name}_compiler(str, path, flags)
        |{
          |this._start = new Date().getTime();
          |this._lexer = new #{@name}_lexer(str);
          |this._parser = new #{@name}_parser();
          |this._executable = null;
          |this._code = str;
          |this._dependencies = [];
          |this._flags = flags;
          |this._path = path;
        |}
        |#{@name}_compiler.prototype.parse = function()
        |{
          |var start = new Date().getTime();
          |var matches = this._lexer.matches();
          |#{
          #console.log("Matching: " + (new Date().getTime() - start));
          }
          |start = new Date().getTime();
          |var tokens = this._lexer.tokens();
          |#{
          #console.log("Lexing: " + (new Date().getTime() - start));
          }
          |try {
            |start = new Date().getTime();
            |var derivation = this._parser.parse(tokens);
            |
            #{
            #console.log("Parsing: " + (new Date().getTime() - start));
            }
          |} catch (e) {
            |var index = e - 1;
            |var error = "Unexpected token: " + matches[index] + "\\n\\n";
            |for (var i = Math.max(index - 20, 0); i < Math.min(matches.length, index + 10); i++)
            |{
              |error += i == index ? ("  " + matches[i] + "  ") : matches[i];
            |}
            |error += "\\n\\nRegex matched: " + tokens[index];
            |throw(error);
          |}
          |start = new Date().getTime();
          |var result = this._parser.compile(matches, derivation);
          |
          #{
          #console.log("Compiling: " + (new Date().getTime() - start));
          #console.log("Time: " + (new Date().getTime() - this._start));
          #console.log(result);
          }
          |return new Executable(result[0], result[1]);
        |}
        |function preprocess(str, path, flags)
        |{
          |return new #{@name}_compiler(str, path, flags).parse();
        |}
      end
      result + generate_lexer_single + generate_parser_single + "\n" + @footer
    end
        
  end
  
end
