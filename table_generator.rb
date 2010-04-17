#!macruby
# coding: utf-8
# 
# table_generator.rb
#
# Created by Erik Österlund on 1/14/10.
# Copyright 2010 Växjö Universitet. All rights reserved.
#

require 'utilities'
require 'set'

module LALR
  
  class Item
    attr_accessor :rule, :dot, :link, :la, :set, :changed
    
    def initialize(rule, dot)
      @rule, @dot = rule, dot
      @changed = false
    end
    
    def ==(arg)
      return false if arg == nil
      arg.rule == rule and arg.dot == dot
    end
    
    def hash
      @rule.name.hash
    end
    
    def to_s
      str = "[ " + @rule.name.to_s + " -> "
      (0...@rule.productions.size).each do |i|
        str << ". " if i == @dot
        str << @rule.productions[i].to_s + " "
      end
      str << ". " if @dot == @rule.productions.size
      if @la
        str << ", "
        @la.each{|la|
          str << la.to_s + " "
        }
      end
      str << "]"
      str
    end
    
    # Return the next item in the rule by following the link
    def next_item
      return nil if @link == nil
      link.kernel.select {|item| item.rule == @rule}.first
    end
    
    # Return the next items by checking for rules in the same set
    def next_items_in_set(set)
      set.items.select{|item| item.rule.name == @rule.productions[@dot]}
    end
    
    # Goes next off times
    def offset(off)
      return self if off == 0
      next_item.offset(off - 1)
    end
    
    def first_with_la(off)
      f = offset(off).first
      return f unless f == Set[Epsilon.instance]
      return @la unless @la == nil
      Set[Epsilon.instance]
    end
    
    def first
      first_rec(Set[])
    end
    
    def first_rec(done)
      symbol = @rule.productions[@dot]
      return Set[Epsilon.instance] if symbol == nil or done.include? self
      done << self
      return Set[@rule.productions[@dot]] unless symbol.is_a? Symbol
      s = Set.new
      next_items_in_set(@set).each do |item|
        item_first = item.first_rec(done)
        s |= item_first unless item_first == Set[Epsilon.instance]
      end
      return next_item.first_rec(done) if s.empty?
      s
    end
    
    ItemLA = Struct.new(:item, :la)
    
    # A non-recursive version of add lookahead (stack level may become too big sometimes otherwise!)
    # Recursively adds all la cascading around in the tables. But without using recursion.
    def add_la(la)
      p1 = [ItemLA.new(self, la)]
      p2 = []
      p3 = []
      
      while p1.size > 0 or p2.size > 0 or p3.size > 0
        if p1.size > 0
          ila = p1.pop
          if ila.item.la == nil
            ila.item.la = ila.la.dup
          else
            new_la = ila.la.union(ila.item.la)
            next if new_la == ila.item.la
            ila.item.la = new_la
          end
          p2.push ila
        elsif p2.size > 0
          ila = p2.pop
          
          next_step = ila.item
          counter = 1
          
          while (next_step != nil)
            symbol = next_step.rule.productions[next_step.dot]
            if symbol.is_a? Symbol
              ila.item.next_items_in_set(ila.item.set).each do |item|
                p1.push ItemLA.new(item, ila.item.first_with_la(counter))
              end
            end
            
            counter += 1
            next_step = next_step.next_item
          end
          
          p3.push(ila)
        elsif p3.size > 0
          ila = p3.pop
          
          ila.item.set.items.each do |item|
            item.link.kernel.each do |linked_item|
              p1.push ItemLA.new(linked_item, item.la) if item.la != nil
            end if item.link != nil
          end
          
        end
      end
    end
    
    # Recursively fixes all rules la from a given start symbol
    def add_la_rec(la)
      if @la == nil
        @la = la.dup
      else
        new_la = la.union(@la)
        return if new_la == @la
        @la = new_la
      end
      next_step = self
      counter = 1
      while next_step != nil
        symbol = next_step.rule.productions[next_step.dot]
        if symbol.is_a? Symbol
          next_items_in_set(@set).each do |item|
            f = first_with_la(counter)
            item.add_la f
          end
        end
        next_step = next_step.next_item
        counter += 1
      end
      
      @set.items.each do |item|
        item.link.kernel.each do |linked_item|
          linked_item.add_la item.la if item.la != nil# and (linked_item.la == nil or linked_item.la.union(item.la) != linked_item.la)
        end if item.link != nil
      end
      
    end
    
    alias eql? ==
  end
  
  class ItemSet
    attr_reader :kernel, :items
    
    def reverse_ref(item)
      @reverse_ref << item
    end
    
    def hash
      @items.first.hash
    end
    
    def initialize(rules, args = nil)
      @reverse_ref = []
      @rules = {}
      case rules
        when Hash
          rules.each do |k, v|
            @rules[k] = v.dup
          end
        when Array
          rules.each {|rule|
            @rules[rule.name] = [] if @rules[rule.name] == nil
            @rules[rule.name] << rule
          }
      end
      @items = []
      case args
        when Item
          @items << args
          @kernel = [args]
        when Array
          @items = args.dup
          @kernel = args.dup
      end
    end
    
    def closure
      result = ItemSet.new(@rules, @kernel)
      pos = 0
      while pos < result.items.length
        item = result.items[pos]
        rule = item.rule
        dotted = rule.productions[item.dot]
        if dotted.is_a? Symbol and @rules[dotted].is_a? Array
          @rules[dotted].each do |r|
            item = Item.new(r, 0)
            result.items << item unless result.items.include? item
          end
        end
        pos += 1
      end
      result
    end
    
    # cache maps a kernel to a set, to avoid circles
    def next_sets(cache)
      result = {}
      @items.each do |item|
        rule = item.rule
        dot = item.dot
        dotted = rule.productions[dot]
        
        if dot < rule.productions.length
          result[dotted] = [] if result[dotted] == nil
          result[dotted] << item
        end
      end
      
      res = []
      result.each do |symbol, items|
        new_items = []
        items.each{|item| new_items << Item.new(item.rule, item.dot + 1)}
        cached = cache[new_items]
        if cached
          set = cached
        else
          set = ItemSet.new(@rules, new_items).closure
        end
        
        items.each do |item|
          item.link = set
          set.reverse_ref item
        end
        
        res << set
      end
      res
    end
    
    def ==(arg)
      return false if arg == nil
      return false unless arg.items.size == @items.size
      (0...@items.size).each do |n|
        return false unless @items[n] == arg.items[n]
      end
      true
    end
    
    alias eql? ==
    
    def to_s
      str = "set {\n"
      @kernel.each{|item| str << "k " + item.to_s + "\n"}
      @items.select{|item| not @kernel.include? item}.each do |item|
        str << "  " + item.to_s + "\n"
      end
      str << "}"
      str
    end
    
  end
  
  class TableGenerator
    
    def initialize(rules)
      @rules = rules.dup
    end
    
    def generate_item_sets()
      grammar = @rules # already augmented grammar
      
      start_item = ItemSet.new grammar, Item.new(grammar[0], 0)
      start_item = start_item.closure
      start_item.items.each{|item| item.set = start_item}
      sets = [start_item]
      new_sets = sets.dup
      
      cache = {start_item.kernel => start_item}
      
      while new_sets.size > 0
        next_sets = []
        new_sets.each do |set|
          set.next_sets(cache).each do |s|
            if cache[s.kernel] == nil
              next_sets << s
              sets << s
              s.items.each{|item|item.set = s}
              cache[s.kernel] = s
            end
          end
        end
        new_sets = next_sets
      end
      sets
    end
    
    # A list of all rules by traversing the sets
    def extended_grammar(sets)
      rules = []
      sets.each do |set|
        set.items.each do |item|
          if item.dot == 0
            rule = [item]
            next_item = item.next_item
            while next_item != nil
              rule << next_item
              next_item = next_item.next_item
            end
            rules << rule
          end
        end
      end
      rules
    end
    
    public
    def generate_tables()
      sets = generate_item_sets()
      extended = extended_grammar(sets)
      extended[0][0].add_la Set[EOF.instance]
      set_to_num = {}
      sets.size.times {|n| set_to_num[sets[n]] = n}
      rule_to_num = {}
      @rules.size.times {|n| rule_to_num[@rules[n]] = n}
      
      gotos = []
      actions = []
      
      sets.each do |set|
        goto_row = {}
        action_row = {}
        
        set.items.each do |i|
          symbol = i.rule.productions[i.dot]
          if symbol == nil
            action_row[EOF.instance] = accept() if i.rule == @rules[0]
            next
          end
          if symbol.is_a? Symbol
            goto_row[symbol] = set_to_num[i.link]
          else
            action_row[symbol] = shift(set_to_num[i.link])
          end
        end
        gotos << goto_row
        actions << action_row
      end
      
      extended.each do |ext_rule|
        rule_root = ext_rule.first
        rule_end = rule_root.offset(rule_root.rule.productions.size)
        set_num = set_to_num[rule_end.set]
        rule_num = rule_to_num[rule_root.rule]
        rule_root.la.each do |la|
          actions[set_num][la] = reduce(rule_num) if actions[set_num][la] == nil
        end
      end
      
      [actions, gotos]
    end
  end
  
end