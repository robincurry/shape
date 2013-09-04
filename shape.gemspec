# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'shape/version'

Gem::Specification.new do |s|
  s.name        = 'shape'
  s.version     = Shape::VERSION
  s.summary     = 'Shape your api'
  s.description = 'Shape your api. Extracted from Vitals Platform.'
  s.authors     = ['Robin Curry', 'Brandon Westcott', 'Tim Morgan']
  s.email       = ['robin.curry@vitals.com', 'brandon.westcott@vitals.com', 'tim.morgan@vitals.com']
  s.homepage    = 'https://github.com/robincurry/shape'
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '>= 3.0'
end
