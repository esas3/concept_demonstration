# require 'appscript'
require 'nokogiri'
require 'open-uri'

module Commonsense
  module Importer
    class EsaImport
      def self.import
        
        
        plainUrl = "http://www.esa.int/SPECIALS/GSP/"
        download = []
        [
          "http://www.esa.int/SPECIALS/GSP/SEMBHQYO4HD_0.html", 
          "http://www.esa.int/SPECIALS/GSP/SEMJIQYO4HD_0.html",
          "http://www.esa.int/SPECIALS/GSP/SEMMHQYO4HD_0.html"  
        ].each do |url|
          doc = Nokogiri::HTML(open(url))
        
          # Get all links
        
        
          links = doc.xpath("//a")
          links.each do |link|
            if link.content =~ /^\d{2,}\/.{3,}/
              #puts "\n#{link.content}: #{link['href']}"
              summary = Nokogiri::HTML(open("#{plainUrl}#{link['href']}"))
              summary_links = summary.xpath("//a")
              summary_links.each do |slink|

                if slink.content == "Executive summary"
                  #puts "\n#{slink.content}: #{slink['href']}"
                  download << slink['href']
                end  
              end
            end
          end
        
        end
      
        download.each do |download|
          system("cd #{File.dirname(__FILE__)}/esa_corpus && curl -O '#{download}'")

        end
          
      end
    end
  end
end