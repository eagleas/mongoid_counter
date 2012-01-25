# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'mongoid_counter/version'

Gem::Specification.new do |s|
  s.name        = 'mongoid_counter'
  s.version     = MongoidCounter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Anton Oryol', 'Alexander Oryol']
  s.email       = ['eagle.anton@gmail.com', 'eagle.alex@gmail.com']
  s.homepage    = 'https://github.com/eagleas/mongoid_counter'
  s.summary     = %q{Add counter ability to Mongoid documents}
  s.description = %q{Add counter ability to Mongoid documents.}

  s.add_dependency 'mongoid'
  s.add_dependency 'bson_ext'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'fabrication'
  s.add_development_dependency 'database_cleaner'

  s.rubyforge_project = 'mongoid_counter'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = ['lib']
end
