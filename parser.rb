#!macruby
# coding: utf-8
# 
# parser.rb
#
# Created by Erik Österlund on 1/14/10.
# Copyright 2010 Växjö Universitet. All rights reserved.
#

require 'singleton'
require 'utilities'

module LALR
  
  class Parser
    
    def initialize(actions, gotos, rules)
      @actions, @gotos, @rules = actions, gotos, rules
    end
    
    def parse(str)
      @inp = str
      init_parsing
      while not @accepted and not @error
        parse_loop
      end
      
      @out
    end
    
    private
    def init_parsing
      @out = []
      @stack = []
      @pos = 0
      @accepted = false
      @error = nil
      shift 0
    end
    
    private
    def next_token
      result = @inp[@pos]
      @pos += 1
      return result unless result.nil?
      EOF.instance
    end
    
    private
    def parse_loop
      action = @actions[@stack.last][@token]
      if action == nil
        error
      else
        action.exec self
      end
    end
    
    private
    def shift(state)
      @stack << state
      @token = next_token
    end
    
    private
    def reduce(rule_number)
      state = @stack.last
      @out << rule_number
      rule = @rules[rule_number]
      @stack.slice!(-rule.productions.length..-1)
      state = @stack.last
      @stack << @gotos[state][rule.name]
    end
    
    private
    def accept()
      @accepted = true
      p "Succeeded."
    end
    
    private
    def error()
      @error = "Something didn't work out"
      p "Error: " + @error
    end
    
  end
  
end