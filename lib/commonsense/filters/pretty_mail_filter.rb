require 'tmail'

module Commonsense
  module Filters
    class PrettyMailFilter
      def self.filter(document)
        document.reload_document
        if document.document[:type] == "mail"
          document.name = document.document[:subject]
        end
      end
    end
  end
end

class Commonsense::Core::Document
  before_save do |document|
    Commonsense::Filters::PrettyMailFilter.filter(document)
  end
end