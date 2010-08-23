require 'sinatra'
require File.join(File.dirname(__FILE__), 'commonsense')

include Commonsense::Core

# class RestServer < Sinatra::Application

get %r{^/(?:stats)?(?:\.([\w]+))?$} do |format|
  format ||= "json"
  {
    "id" => "common_sense", "version" => "1",
    "stats" => {
      "documents" => Document.count,
      "tags" => Tag.count,
      "users" => User.count
    }
  }.send("to_#{format}")
end

get %r{^/documents(?:\.([\w]+))?$} do |format|
  format ||= "json"
  Document.all.send("to_#{format}", :methods => [:summary, :doc_type])
end

post  %r{^/documents(?:\.([\w]+))?$} do |format|
  format ||= "json"
  d = Document.new(
    :name => params[:name], 
    :document => params[:document],
    :created_at => (DateTime.parse(params[:created_at]) rescue nil)
  )
  if d.save
    "ok"
  else
    puts d.errors.full_messages.inspect
    halt 409, d.errors.to_json
  end
end

get '/documents/search/:query' do
  uri = Commonsense::Config[:keyword_index]
  
  response = eval(RestClient.get(uri+"?wt=ruby&fl=id+title+score+content_type&hl=true&hl.fl=attr_content&q=#{CGI.escape params[:query]}").body)
  documents = response["response"]["docs"].map do |doc|
    doc.merge({
      :snippets => response["highlighting"][doc["id"]].collect { |k,v| v }.flatten,
      :summary => response["highlighting"][doc["id"]].collect { |k,v| v }.join(" ... "),
      :doc_type => doc["content_type"].first,
      :name => doc["title"] && doc["title"].first || doc["id"],
      :uri => doc["id"]
    })
  end
  documents.to_json
end

get '/documents/:id/temporally_related' do
  d = Document.find(params[:id])
  d ||= Document.find_by_uri(params[:id])
  params[:dt] ||= 5
  dt = params[:dt].to_i.days
  from = d.created_at - dt
  to = d.created_at + dt
  options = { :conditions => { :created_at => from..to } }
  dt_documents = Document.all(options.merge(:limit => 50))
  dt_documents.to_json(:methods => [:summary, :doc_type])
end

get %r{^/documents/by_name(?:\.([\w]+))?} do |format|
  format ||= "json"
  Document.all(
    :conditions => [ 'name LIKE ?', "%#{params[:name]}%" ],
    :limit => 25
  ).to_json(:methods => [ :summary, :doc_type ])
end

get %r{^/documents/by_uri(?:\.([\w]+))?} do |format|
  format ||= "json"
  Document.all(
    :conditions => [ 'uri LIKE ?', "%#{params[:uri]}%" ],
    :limit => 25
  ).to_json(:methods => [ :summary, :doc_type ])
end

get '/documents/:id' do
  d = Document.find(params[:id])
  d ||= Document.find_by_uri(params[:id])
  methods = [:summary, :doc_type]
  methods << :document if params[:include_doc] == "true"
  JSON.parse(d.to_json(
    :methods => methods, 
    :include => { 
      :outgoing_document_relations => { 
        :include => [:destination, :ratings]
      },
      :ratings => {}
    }
  )).merge!(
    :related_documents => d.relations,
    :tags => d.tags
  ).to_json
end

post %r{^/tags(?:\.([\w]+))?$} do |format|
  if t = Tag.create(:name => params[:name])
    "ok"
  else
    halt 405, t.errors.to_json
  end
end

get '/tags/by_name/:name' do
  Tag.all(:conditions => ['name LIKE ?', "%#{params[:name]}%"]).to_json
end

get '/tags/documents' do
  uri = Commonsense::Config[:rdf_store]
  
  query = %Q{
    PREFIX foaf:<http://xmlns.com/foaf/0.1/>
    PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#>

    SELECT DISTINCT ?document WHERE {
      ?document foaf:primaryTopic ?topic .
      ?topic rdfs:subClassOf <#{params[:id]}>
    }
  }
  
  request = RestClient.get(uri+"?query="+CGI.escape(query), :accept => "application/sparql-results+json")
  response = JSON.parse(request.body)
  puts response.inspect
  response["results"]["bindings"].collect { |b| 
    { :id => b["document"]["value"] } 
  }.to_json
  
end

get %r{^/tags(?:\.([\w]+))?} do |format|
  uri = Commonsense::Config[:rdf_store]
  
  query = %q{
    PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#>
    PREFIX phys:<http://sweet.jpl.nasa.gov/2.0/phys.owl#>
    PREFIX foaf:<http://xmlns.com/foaf/0.1/>
    PREFIX owl:<http://www.w3.org/2002/07/owl#>
    PREFIX astroPlanet:<http://sweet.jpl.nasa.gov/2.0/astroPlanet.owl#>
    PREFIX sesame:<http://www.openrdf.org/schema/sesame#>

    SELECT DISTINCT ?class ?directsuperclass WHERE {
      ?class sesame:directSubClassOf ?directsuperclass . 
      { ?directsuperclass rdfs:subClassOf astroPlanet:PlanetaryRealm } UNION 
      { ?directsuperclass rdfs:subClassOf phys:PhysicalPhenomena }
    }
  }
  
  request = RestClient.get(uri+"?query="+CGI.escape(query), :accept => "application/sparql-results+json")
  response = JSON.parse(request.body)
  puts response.inspect
  response["results"]["bindings"].collect { |b| 
    { :name => b["class"]["value"], :superclass => b["directsuperclass"]["value"] } 
  }.to_json
end


get %r{^/document_relations(?:\.([\w]+))?$} do |format|
  format ||= "json"
  DocumentRelation.all.send("to_#{format}")
end

post %r{^/document_relations(?:\.([\w]+))?$} do |format|
  format ||= "json"
  begin
    DocumentRelation.create_undirected(Document.find(params[:one]), Document.find(params[:two]))
    "ok"
  rescue
    halt 409, $!.inspect
  end
end

get %r{^/tag_document_relations(?:\.([\w]+))?$} do |format|
  format ||= "json"
  TagDocumentRelation.all.send("to_#{format}")
end

post %r{^/tag_document_relations(?:\.([\w]+))?$} do |format|
  format ||= "json"
  if r = TagDocumentRelation.create(:tag => Tag.find(params[:tag]), :document => Document.find(params[:document]))
    "ok"
  else
    halt 409, r.errors.send("to_#{format}")
  end
end

get '/tag_relations' do
  TagRelation.all.to_json
end

post '/tag_relations' do
  if r = TagRelation.create_undirected(Tag.find(params[:one]), Tag.find(params[:two]))
    "ok"
  else
    halt 409, r.errors.to_json
  end
end

get %r{^/ratings(?:\.([\w]+))?$} do |format|
  format ||= "json"
  Rating.all.send("to_#{format}")
end

post %r{^/ratings(?:\.([\w]+))?$} do |format|
  format ||= "json"
  r = Rating.new(:name => params[:name], :value => params[:value], :rateable_id => params[:rateable_id], :rateable_type => params[:rateable_type])
  if r.save
    "ok"
  else
    halt 409, r.errors.send("to_#{format}")
  end
end

get %r{^/users(?:\.([\w]+))?$} do |format|
  format ||= "json"
  User.all.send("to_#{format}")
end

get %r{^/users/by_name(?:\.([\w]+))?$} do |format|
  format ||= "json"
  name = params[:name].split
  conditions = { :first_name => name.first, :last_name => name.last }
  User.all(:conditions => conditions).send("to_#{format}")
end

get %r{^/users/(\d+)(?:\.([\w]+))?$} do |user_id, format|
  format ||= "json"
  User.find(user_id).send("to_#{format}")
end

get %r{^/users/(\d+)/documents(?:\.([\w]+))?$} do |user_id, format|
  format ||= "json"
  User.find(user_id).documents.send("to_#{format}", :methods => [:summary, :doc_type])
end


get '/search/time' do
  from = Date.parse(params[:from])
  to = Date.parse(params[:to])
  options = { :conditions => { :created_at => from..to } }
  {
    :users => User.all(options), 
    :documents => Document.all(options), 
    :tags => Tag.all(options),
    :document_relations => DocumentRelation.all,
    :tag_relations => TagRelation.all,
    :tag_document_relations => TagDocumentRelation.all
  }
end


get '/graphs/documents' do
  {
    :documents => Document.all,
    :relations => DocumentRelation.all
  }.to_json
end

get '/graphs/tags' do
  {
    :tags => Tag.all,
    :relations => TagRelation.all
  }.to_json
end

get '/graphs/full' do
  {
    :users => User.all, 
    :documents => Document.all, 
    :tags => Tag.all,
    :document_relations => DocumentRelation.all,
    :tag_relations => TagRelation.all,
    :tag_document_relations => TagDocumentRelation.all
  }.to_json
end

get '/graphs/tags/tree/:id' do |tag_id|
  tag = Tag.find(tag_id)
  
  
  {
    :id => tag.id,
    :name => tag.name,
    :children => tag.documents.collect{|d| 
      {:id => d.id, :name => d.name} 
    }
  }.to_json
  
end

# end
