require 'rubygems'
require 'bundler'
Bundler.setup

require 'mongoid'
Mongoid.configure do |config|
  logger = Logger.new('log/test.log')
  config.master = Mongo::Connection.new('localhost', 27017, logger: logger).db('mongoid_counter_test')
  config.autocreate_indexes = true
  config.logger = logger
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'mongoid_counter'
require 'rspec'
require 'rspec/autorun'
require 'fabrication'

models_folder = File.join(File.dirname(__FILE__), 'models')
Dir[ File.join(models_folder, '*.rb') ].each { |file|
  require file
  file_name = File.basename(file).sub('.rb', '')
  klass = file_name.classify.constantize
  klass.collection.drop
}

require 'database_cleaner'
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    Mongoid.database.collections.each{|c| c.drop_indexes }
  end

  config.before(:each) do
    DatabaseCleaner[:mongoid].clean
  end
end
