module Commonsense
  module Core
    class Tag < ActiveRecord::Base

      has_many :incoming_tag_relations, 
                  :class_name => "TagRelation", 
                  :foreign_key => "destination_id",
                  :dependent => :destroy
      has_many :outgoing_tag_relations, 
                  :class_name => "TagRelation", 
                  :foreign_key => "source_id",
                  :dependent => :destroy

      has_many :sources, :through => :incoming_tag_relations
      has_many :destinations, :through => :outgoing_tag_relations

      has_many :tag_document_relations, :dependent => :destroy
      has_many :documents, :through  => :tag_document_relations
      
      belongs_to :user
      
      has_many :ratings, :as => :rateable, :dependent => :destroy

      alias_method :relations, :destinations
    end
  end
end
