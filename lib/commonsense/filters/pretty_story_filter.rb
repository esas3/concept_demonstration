module Commonsense
  module Filters
    class PrettyStoryFilter
      def self.filter(document)
        document.reload_document
        if document.document[:type] == "story"
          document.name = document.document[:name]
        end
      end
    end
  end
end

class Commonsense::Core::Document
  before_save do |document|
    Commonsense::Filters::PrettyStoryFilter.filter(document)
  end
end