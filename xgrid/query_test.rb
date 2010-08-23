#!/usr/bin/env ruby

require 'cgi'
require 'net/http'

$host = "10.0.0.10"
$port = 4567

def keyword_query
  %w(esa launcher satellite).each do |query|
    Net::HTTP.get_print($host,"/documents/search/#{CGI.escape(query)}", $port)
  end
end

def concept_query
  Net::HTTP.get_print($host,"/tags", $port)
end

def combined_query
  keyword_query
  concept_query
end

query_type = ARGV.first
queries_per_worker = ARGV.last.to_i

queries_per_worker.times do
  eval query_type
end