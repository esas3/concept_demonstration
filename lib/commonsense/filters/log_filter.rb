module Commonsense
  module Filters
    class LogFilter
      def self.filter(document)
        puts "#{document.id}: #{document.uri}"
      end
    end
  end
end

class Commonsense::Core::Document
  after_save do |document|
    Commonsense::Filters::LogFilter.filter(document)
  end
end