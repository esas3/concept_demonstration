module Commonsense
  module Filters
    class StoryCommitDocumentFilter
      def self.filter(document)
        document.reload_document
        if document.document[:type] == "commit"
          regex = /\[.*#\s*(\d+).*\]/
          if document.document[:message] =~ regex
            story_id = $1
            uri = document.uri[0..document.uri.rindex("/")]
            uri += "Story%2F#{story_id}"
            story = Commonsense::Core::Document.find_by_uri(uri)
            Commonsense::Core::DocumentRelation.create_undirected(document, story)
          end
        end
      end
    end
  end
end

class Commonsense::Core::Document
  after_save do |document|
    Commonsense::Filters::StoryCommitDocumentFilter.filter(document)
  end
  
end