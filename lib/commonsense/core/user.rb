module Commonsense
  module Core
    class User < ActiveRecord::Base
      has_many :incoming_user_relations, 
                  :class_name => "UserRelation", 
                  :foreign_key => "destination_id",
                  :dependent => :destroy
      has_many :outgoing_user_relations, 
                  :class_name => "UserRelation", 
                  :foreign_key => "source_id",
                  :dependent => :destroy
      
      
      has_many :sources, :through => :incoming_user_relations
      has_many :destinations, :through => :outgoing_user_relations
      
      alias_method :relations, :destinations
      
      has_many :documents, :dependent => :destroy
      has_many :tags, :dependent => :destroy
      
      
      has_many :ratings, :as => :rateable, :dependent => :destroy
      
      def merge!(user)
        transaction do
          user.documents.each do |document|
            document.user = self
            document.save!
          end
          user.tags.each do |tag|
            tag.user = self
            tag.save!
          end
          user.destroy
        end
      end
    end
  end
end