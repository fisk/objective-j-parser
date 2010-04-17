#!macruby
# coding: utf-8
# 
# utilities.rb
#
# Created by Erik Österlund on 1/14/10.
# Copyright 2010 Växjö Universitet. All rights reserved.
#

require 'parser'

module LALR
  
  class Rule
    attr_accessor :name, :productions
    
    def initialize(name, productions)
      @name, @productions = name, productions
    end
    
    def to_s
      str = @name.to_s + " -> "
      @productions.each do |p|
        str << p.to_s + " "
      end
      str
    end
    
    def hash()
      @name.hash + @productions.hash
    end
    
    def ==(arg)
      @name == arg.name and @productions == arg.productions
    end
    
    def eql?(arg)
      @name == arg.name and @productions == arg.productions
    end
    
    def epsilon?()
        (productions.include?(Epsilon.instance)) or productions.length == 0
    end
  end
  
  def shift(num)
    Action.new :shift, num
  end
  
  def reduce(num)
    Action.new :reduce, num
  end
  
  def accept()
    Action.new :accept
  end
  
  class Action
    attr_accessor :action, :number
    
    def initialize(action, number = nil)
      @number, @action = number, action
    end
    
    def exec(sender)
      if @number
        sender.send @action, @number
      else
        sender.send @action
      end
    end
    
    def to_s
      @action[0].to_s + (@number != nil ? @number.to_s : "")
    end
    
    def eql?(arg)
      @action == arg.action and @number == arg.number
    end
    
    def hash
      @action.hash
    end
  end
  
  class EOF
    include Singleton
    def to_s
      "$"
    end
  end
  
  class Epsilon
    include Singleton
    def to_s
      "ε"
    end
  end
  
end