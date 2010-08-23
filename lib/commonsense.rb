# Puts actual path in loadpath
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  
#require 'mongo_mapper'
require 'couchrest'
require 'sinatra'
require 'rest_client'
require 'commonsense/config'
require 'rgl/base'
require 'active_record'
require 'yaml'
require 'nokogiri'

require 'commonsense/config'


#Load Active Record Configuration
dbconfig = YAML::load(File.open(File.join(File.dirname(__FILE__), '..', 'database.yml')))
ActiveRecord::Base.establish_connection(dbconfig)
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'a'))

Commonsense::Config.database  CouchRest.database!("http://localhost:5984/commonsense-test")
Commonsense::Config.rdf_store "http://localhost:8080/openrdf-sesame/repositories/ESA"
Commonsense::Config.keyword_index "http://localhost:8983/solr/select/"

CouchRest::Document.use_database Commonsense::Config[:database]


require 'commonsense/core/document'
# for now, require all of core
Dir[File.join(File.dirname(__FILE__), 'commonsense', 'support', '*.rb')].each { |lib| require lib }
Dir[File.join(File.dirname(__FILE__), 'commonsense', 'core', '*.rb')].each { |lib| 
  require lib unless lib =~ /document\.rb/
}
Dir[File.join(File.dirname(__FILE__), 'commonsense', 'filters', '*.rb')].each { |lib| require lib }
Dir[File.join(File.dirname(__FILE__), 'commonsense', 'importer', '*.rb')].each { |lib| require lib }
Dir[File.join(File.dirname(__FILE__), 'commonsense', 'services', '*.rb')].each { |lib| require lib }
