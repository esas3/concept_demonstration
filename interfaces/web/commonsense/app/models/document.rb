class Document < ActiveResource::Base
  self.site = "http://localhost:4567"
  self.format = :json
  
  def raw_uri
    @raw_uri ||= begin
      uri = self.uri[14..-1]
      uri.gsub!("localhost:5984/", "localhost:5984/_utils/document.html?")
      prefix = "http://"
      uri = prefix + uri unless uri.start_with?(prefix)
      uri
    end
  end
end