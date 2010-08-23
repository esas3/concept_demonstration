#!/usr/bin/env ruby -rubygems

require 'active_support'

directory = "/tmp/query_test"

Dir.mkdir(directory) rescue nil
`cp query_test.rb #{directory}`

queries_per_worker = 10
total_queries = 1000
query_type = "keyword_query"


cmd = "xgrid -h localhost -in #{directory} -job submit /opt/local/bin/ruby query_test.rb  #{query_type} #{queries_per_worker}"

(total_queries/queries_per_worker).times do 
  system cmd
end