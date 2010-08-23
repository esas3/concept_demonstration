module Commonsense
  module Core
    class TagDocumentRelation < ActiveRecord::Base
      belongs_to :tag, :counter_cache => true
      belongs_to :document, :counter_cache => true
      belongs_to :user
      
      has_many :ratings, :as => :rateable, :dependent => :destroy
    end
  end
end
