module Commonsense
  module Core
    class Rating < ActiveRecord::Base
      belongs_to :rateable, :polymorphic => true, :counter_cache => true
    end
  end
end