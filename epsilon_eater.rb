#!ruby
# coding: utf-8
# 
# epsilon_eater.rb
#
# Created by Erik Österlund on 4/12/10.
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
require 'utilities'

module LALR

class Rule
  attr_accessor :original_rule, :epsilon_indices
end

class EpsilonEater
    attr_accessor :rules, :old_rules, :rule_evaluators, :new_rules, :deleted_rules
    
    def initialize(rules, rule_evaluators)
      @rules = rules.dup
      @old_rules = rules
      @deleted_rules = []
      @new_rules = []
      @rule_evaluators = rule_evaluators.dup
    end
    
    def traverse_combination_tree(elements, k, choice)
      return [] if elements.empty? or k == 0
      result = [elements[choice]]
      (choice..elements.length - k).each do |new_choice|
        new_pick = traverse_combination_tree(elements.reject{|i| i == elements[choice]}, k - 1, new_choice)
        result << new_pick unless new_pick.empty?
      end
      result
    end

    def flatten_combination_tree(tree, result, sub_result)
      sub_res = sub_result.dup
      children = 0
      tree.each do |node|
        sub_res << node if node.is_a? Integer
        if node.is_a? Array
          flatten_combination_tree(node, result, sub_res)
          children += 1
        end
      end
      if children == 0
        result << sub_res
      end
    end
    
    # Get the combinations of ways the elements can be picked if k elements are to be picked
    def combinations(elements, k)
      sub_res = []
      (0..elements.length - k).each do |i|
        sub_res << traverse_combination_tree(elements, k, i)
      end
      result = []
      flatten_combination_tree(sub_res, result, [])
      result
    end
    
    # Get the combinations of ways the elements can be picked if UP TO k elements are to be picked
    def combinations_to(elements, k)
      result = []
      (1..k).each do |i|
        result |= combinations(elements, i)
      end
      result << []
      result
    end
    
    # Returns all rules containing an epsilon production
    def rules_with_epsilon()
      rules = []
      @rules.each do |rule|
        rules << rule if rule.epsilon?
      end
      rules
    end
    
    # Returns all rules containing a production
    def rules_containing(production)
      rules = []
      @rules.each do |rule|
        rules << rule if rule.productions.include?(production)
      end
      rules
    end
    
    # Creates all permutations of rules for the specified rule and production
    def rule_permutations(rule, production)
      indices = []
      productions = rule.productions
      productions.count.times do |i|
        indices << i if productions[i] == production
      end
      index_perms = combinations_to indices, indices.count
      new_rules = []
      index_perms.each_with_index do |index_perm, i|
        new_prods = []
        productions.each_with_index do |p, j|
            new_prods << p unless index_perm.include? j
        end
        new_prods << Epsilon.instance if new_prods.count == 0
        new_rule = Rule.new(rule.name, new_prods)
        new_rule.original_rule = rule
        new_rule.epsilon_indices = index_perm
        new_rules << new_rule
      end
      new_rules
    end
    
    def get_rid_of_epsilons()
      while (rwe = rules_with_epsilon).length > 0
        rwe.each do |rwe_rule|
          production = rwe_rule.name   # production leading to epsilon
          rte = rules_containing(production)
          permutations_tree = []
          rte.each do |rte_rule|
            permutations = rule_permutations(rte_rule, production)
            accepted_permutations = []
            permutations.each do |permutation|
              accepted_permutations << permutation unless permutation.epsilon? and permutation.name == rwe_rule.name
            end
            permutations_tree << accepted_permutations
          end
          @rules.delete(rwe_rule)
          @deleted_rules << rwe_rule
          permutations_tree.each do |insert_these|
            insert_these.each do |permutation|
              @new_rules << permutation unless @old_rules.include?(permutation)
              @rules << permutation unless @old_rules.include?(permutation) or @rules.include?(permutation)
              #@rule_evaluators[permutation] = @rule_evaluators[permutation.original_rule] unless @old_rules.include?(permutation) or @rules.include?(permutation)
            end
          end
        end
      end
      
      flatten_originality
    end
    
    def flatten_originality
      depths = {}
      @new_rules.each do |rule|
        next_rule = rule
        depth = 0
        begin
          depth += 1
          next_rule = next_rule.original_rule
        end while next_rule.original_rule
        
        depths[depth] = [] unless depths[depth]
        depths[depth] << rule
      end
      
      depths.sort.reverse_each do |depth, rules|
        rules.each do |rule|
          real_original = rule
          real_epsilon_indices = rule.epsilon_indices.dup
          
          begin
            real_original = real_original.original_rule
            
            super_epsilons = real_original.epsilon_indices
            if super_epsilons
              super_epsilons.each do |super_epsilon|
                real_epsilon_indices.each_with_index{|real_epsilon, index| real_epsilon_indices[index] += 1 if real_epsilon >= super_epsilon}
              end
              real_epsilon_indices = (real_epsilon_indices|super_epsilons).sort
            end
          end while real_original.original_rule
          
          rule.original_rule = real_original
          rule.epsilon_indices = real_epsilon_indices
        end
      end
    end
end

end
