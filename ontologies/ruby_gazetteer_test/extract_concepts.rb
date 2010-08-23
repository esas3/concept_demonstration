#!/usr/bin/env ruby -rubygems

begin
  require 'rdf'
  require 'rdf/raptor'
  require 'active_support'
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
    subclasses << find_instances_of(graph, stmt.subject)
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


def load_graphs(path, format = :rdfxml)
  Dir[path].collect do |file|
    RDF::Graph.load(file, :format => format)
  end.compact
end


def fill_list_for(concept, output_dir = $output_dir)
  concept_name = concept.to_s.split("#").last
  list_file_name = concept_name.underscore + "_list"
  
  # For demonstration purposes, add only a humanized version of the concept
  # name to the list file.
  humanized_name = concept_name.underscore.humanize
  
  puts "Will add '#{humanized_name}' to #{list_file_name}"
  File.open(File.join(output_dir, list_file_name), "w") do |file|
    file.puts humanized_name
  end
  
  list_file_name
end

def write_mapping_definitions(mapping_definitions, output_dir = $output_dir)
  File.open(File.join(output_dir, "mapping_definitions.def"), "w") do |file|
    file.puts mapping_definitions.join("\n")
  end
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
  puts "Finding all subclasses of #{base_class}..."
  find_all_subclasses_of(graphs, base_class)
end.flatten.compact
puts

puts "Generating gazetteer list for each identified concept..."
mapping_definitions = []
subclasses.each do |concept|
  # Fill Gazetteer List
  list_file_name = fill_list_for(concept)
  
  # Entry in the mapping definition:
  # <list_file_name>:<concept_uri>
  mapping_definitions << "#{list_file_name}:#{concept.to_s.gsub("#", ":")}"
end

puts "Writing Mapping definitons..."
write_mapping_definitions(mapping_definitions)