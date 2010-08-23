module Commonsense
  module Filters
    class PrettyCommitFilter
      def self.filter(document)
        document.reload_document
        if document.document[:type] == "commit"
          document.name = document.document[:message].split("\n").first
        end
      end
    end
  end
end

class Commonsense::Core::Document
  before_save do |document|
    Commonsense::Filters::PrettyCommitFilter.filter(document)
  end
end