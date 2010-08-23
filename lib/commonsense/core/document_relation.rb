module Commonsense
  module Core
    class DocumentRelation < ActiveRecord::Base
      belongs_to :source, :class_name => "Document"
      belongs_to :destination, :class_name => "Document", :counter_cache => :outgoing_document_relations_count
      
      belongs_to :user
      
      has_many :ratings, :as => :rateable, :dependent => :destroy
      
      def self.create_undirected(document_one,document_two)
        unless document_one && document_one.destinations.include?(document_two)
          self.create!(:source => document_one, :destination => document_two)
        end
        unless document_two && document_two.destinations.include?(document_one)
          self.create!(:source => document_two, :destination => document_one)
        end
      end
    end
  end
end