class Rating < ActiveResource::Base
  self.site = "http://localhost:4567"
  self.format = :json
  
  def save 
    uri = self.class.site.to_s + self.collection_path[1..-1]
    RestClient.post(uri, attributes)
  end  
end