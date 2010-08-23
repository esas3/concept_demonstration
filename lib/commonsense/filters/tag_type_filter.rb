module Commonsense
  module Filters
    class TagTypeFilter
      def self.filter(document)
        if document.document
          Commonsense::Core::TagDocumentRelation.create!(
            :tag => Commonsense::Core::Tag.find_or_create_by_name(document.document[:type]),
            :document => document
          )
        end
      end
    end
  end

end

class Commonsense::Core::Document
  after_create do |document|
    Commonsense::Filters::TagTypeFilter.filter(document)
  end
end