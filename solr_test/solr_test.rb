require 'rubygems'
# require 'rsolr'
# 
# # Establish conection to solr
# rsolr = RSolr.connect :url => 'http://localhost:8983/solr'
require 'cgi'

# Path to the ESA document corpus
dirname = File.join(File.dirname(__FILE__), "..", "lib", "commonsense", "importer", "esa_corpus")
path = File.join(dirname, "*.pdf")

puts path

Dir[path].each do |file|
  
  id = "file:"+File.expand_path(file)
  
  `curl 'http://localhost:8983/solr/update/extract?literal.id=#{CGI.escape(id)}&uprefix=attr_&fmap.content=attr_content&commit=true' -F myfile=@#{File.expand_path(file)}`
end