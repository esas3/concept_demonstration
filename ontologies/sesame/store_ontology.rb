#!/usr/bin/env ruby -rubygems

begin
  require 'rdf'
  require 'rdf/raptor'
  require 'active_support'
  require 'rest_client'
rescue LoadError
  puts "One or more of the required gems could not be found!"
  puts "Install required gems using\n\tgem install rdf rdf-raptor active_support"
  puts "Also, please make sure to install the `raptor` RDF parser."
  exit
end

dirname = File.join(File.dirname(__FILE__), "..", "SWEET")
path = File.join(dirname, "*.owl")

$output_dir = output_dir = File.join(File.dirname(__FILE__), "gazetteer_files")
Dir.mkdir(output_dir) unless File.exists?(output_dir)

def find_subclasses_of(graph, class_uri)
  subclasses = []
  graph.query([nil, RDF::RDFS.subClassOf, class_uri]) do |stmt|
    print "."; STDOUT.flush
    subclasses << stmt.subject
    subclasses += find_subclasses_of(graph, stmt.subject)
  end
  subclasses
end

def find_all_subclasses_of(graphs, class_uri)
  graphs.collect do |graph|
    find_subclasses_of(graph, class_uri)
  end.flatten.compact
end

def find_instances_of(graph, class_uri)
  graph.query([nil, RDF.type, class_uri]).collect(&:subject)
end

def find_all_instances_of(graphs, class_uri)
  graphs.collect do |graph|
    find_instances_of(graph, class_uri)
  end.flatten.compact
end

def load_graphs(path, format = :rdfxml)
  Dir[path].collect do |file|
    RDF::Graph.load(file, :format => format)
  end.compact
end


# Physical phenomena url: 
# http://sweet.jpl.nasa.gov/2.0/phys.owl#PhysicalPhenomena
sweet_base_uri = "http://sweet.jpl.nasa.gov/2.0"
base_classes = [
  RDF::URI.new("#{sweet_base_uri}/phys.owl#PhysicalPhenomena"),
  RDF::URI.new("#{sweet_base_uri}/astroPlanet.owl#PlanetaryRealm")
]

puts "Loading Ontology..."
graphs = load_graphs(path)

subclasses = base_classes.collect do |base_class|
  puts
  puts "Finding all subclasses of #{base_class}..."
  find_all_subclasses_of(graphs, base_class)
end.flatten.compact

subclasses += base_classes

instances = subclasses.collect do |subclass|
  puts
  puts "Finding instances of #{subclass}..."
  find_all_instances_of(graphs, subclass)
end

rdfxml = RDF::Writer.for(:rdfxml).buffer do |writer|
  (subclasses + instances).each do |sc_uri|
    graphs.each do |g|
      g.query([sc_uri, nil, nil]).each do |stmt|
        writer << stmt
      end
    end
  end  
end

RestClient.post(
  "http://localhost:8080/openrdf-sesame/repositories/ESA/statements",
  rdfxml,
  { :content_type => 'application/rdf+xml;charset=UTF-8' }
)