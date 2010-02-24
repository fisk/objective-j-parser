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
require 'js_compiler'
require 'js_parser'
require 'js_lexer'
require 'js_interpreter_generator_single'

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
  include Marshal
    
    def compiler(arg)
      @compiler = yield.gsub(/\n\s*/m, "")
      @compiler_name = arg
    end
    
    def header()
      @header = yield
    end
    
    def footer()
      @footer = yield
    end
  
    def comment(arg)
      @comments << arg
    end
    
    def commentAmbiguity(arg)
      @commentAmbiguities << arg
    end
  
    def token(arg, literal = nil)
      reg = fix_regex arg if arg.is_a? Regexp
      @token_lit[literal] = @tokens.length if literal
    end
    
    def rule(arg)
      arg.each do |k,v|
        if v.is_a? Array
          v.size.times do |i|
            v[i] = fix_regex v[i] if v[i].is_a? Regexp
          end
          @rules << Rule.new(k, v)
        else
          v = fix_regex v if v.is_a? Regexp
          @rules << Rule.new(k, [v])
        end
      end
      @rule_evaluators << yield.gsub(/\$(\d+)/m){|m|"this.$#{m[1].to_i}.$0"}.
        gsub(/\${2}/m, 'this.$0').gsub(/\@(\d+)/m){|m|"this.$#{m[1].to_i}"}.
        gsub(/\@{2}/m, 'this').gsub(/\n\s*/m, "")
    end
    
    def start(arg)
      @start = arg
    end
    
    def initialize(arg, file)
      @rules = []
      @rule_evaluators = []
      @tokens = []
      @token_lit = {}
      @comments = []
      @commentAmbiguities = []
      @name, @file = arg, file
      @compiler = ""
      @compiler_name = nil
    end
    
    def symbol_to_index
      symbols = Set.new
      @rules.each do |rule|
        symbols << rule.name
      end
      symbols = symbols.to_a
      sm = {}
      symbols.size.times do |i|
        sm[symbols[i]] = i
      end
      sm
    end
    
    def generate_interpreter
      our_dump = dump(@rules.map{|rule|rule.name.to_s + rule.productions.to_s}) + 
        dump(@start) + dump(@tokens.sort{|a, b|a.source <=> b.source}) + dump(@comments.sort{|a, b|a.source <=> b.source})
      current_dump = ""
      File.open(@file + ".grammar", "r"){|f|
        current_dump = f.read
      } if File.exists?(@file + ".grammar")
      
      if Digest::SHA256.digest(our_dump) == Digest::SHA256.digest(current_dump) and 
          File.exists?(@file + ".gotos") and File.exists?(@file + ".actions")
        File.open(@file + ".gotos", "r"){|f|
          @gotos = Marshal.restore(f.read())
        }
        File.open(@file + ".actions", "r"){|f|
          @actions = Marshal.restore(f.read())
        }
        @rules.insert 0, Rule.new(:S, [@start])
      else
        generator = TableGenerator.new(@rules, @start)
        @actions, @gotos = generator.generate_tables
        
        File.open(@file + ".grammar", "w"){|f|
          f.write(our_dump)
        }
        File.open(@file + ".gotos", "w"){|f|
          f.write(Marshal.dump(@gotos))
        }
        File.open(@file + ".actions", "w"){|f|
          f.write(Marshal.dump(@actions))
        }
      end
      
      File.open(@file + ".js", "w"){|f|
        f.write generate_interface
      }
      File.open(@file + "_lexer.js", "w"){|f|
        f.write generate_lexer
      }
      File.open(@file + "_parser.js", "w"){|f|
        f.write generate_parser
      }
      File.open(@file + "_single.js", "w"){|f|
        f.write generate_interface_single
      }
    end
    
    private
    def fix_regex(reg)
      r = Regexp.new("(" + reg.source + ")", Regexp::MULTILINE)
      @tokens << r unless @tokens.include? r
      r
    end
    
    def generate_interface
      <<-end.here_with_pipe
        |function #{@name}_compiler(str, path, bundle, callback)
        |{
          |this._lexer = new Worker('#{@file + "_lexer.js"}');
          |this._parser = new Worker('#{@file + "_parser.js"}');
          |var parser = this._parser;
          |this._executable = null;
          |this._code = str;
          |this._dependencies = [];
          |var dependencies = this._dependencies;
          |this._bundle = bundle;
          |this._path = path;
          |
          |this._lexer.onmessage = function(message)
          |{
            |parser.postMessage(message.data);
          |}
          |
          |this._parser.onmessage = function(message)
          |{
            |callback(new Executable(message.data, dependencies));
          |}
        |}
        |#{@name}_compiler.prototype.parse = function()
        |{
          |this._start = new Date();
          |this._startLexing = this._start;
          |this._lexer.postMessage(this._code);
        |}
        |function preprocess(str, path, bundle, callback)
        |{
          |new #{@name}_compiler(str, path, bundle, callback).parse();
        |}
      end
    end
        
  end
  
end
