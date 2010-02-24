#!ruby
# coding: utf-8
# 
# Rakefile
#
# Created by Erik Österlund on 1/14/10.
# Copyright 2010 Växjö Universitet. All rights reserved.
#

desc "Default task generates the interpretor" 
task :default => [:generate]

desc "Generate the interpretor and cache the grammar"
task :generate
file "generate" => [] do
  puts "generating"
  `ruby1.9 objj_js_generator.rb`
end

desc "Clean away the cached tables and the interpretor" 
task :clean
file "clean" => [] do
  puts "cleaning"
  `rm objj_js.js` if File.exists? "objj_js.js"
  `rm objj_js_single.js` if File.exists? "objj_js_single.js"
  `rm objj_js.grammar` if File.exists? "objj_js.grammar"
  `rm objj_js.actions` if File.exists? "objj_js.actions"
  `rm objj_js.gotos` if File.exists? "objj_js.gotos"
end