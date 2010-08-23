module Commonsense
  module Core
    class UserRelation < ActiveRecord::Base
        belongs_to :source, :class_name => "User"
        belongs_to :destination, :class_name => "User"
        
        has_many :ratings, :as => :rateable, :dependent => :destroy
        
        def self.create_connection(user_one,user_two)
          self.create!(:source => user_one, :destination => user_two)
          self.create!(:source => user_two, :destination => user_one)
        end
    end
  end
end