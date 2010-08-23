module Commonsense
  module Core
    class TagRelation < ActiveRecord::Base
      belongs_to :source, :class_name => "Tag"
      belongs_to :destination, :class_name => "Tag"
      
      belongs_to :user
      
      has_many :ratings, :as => :rateable, :dependent => :destroy
      
      def self.create_undirected(tag_one,tag_two)
        self.create!(:source => tag_one, :destination => tag_two)
        self.create!(:source => tag_two, :destination => tag_one)
      end
    end
  end

end
