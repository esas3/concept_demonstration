module Commonsense
  module Filters
    class UserAssociationFilter
      def self.filter(document)
        unless document.user
          document.reload_document
          payload = document.document
          case payload[:type]
          when "commit"
            name = payload[:author][:name].split
            first_name, last_name = [name.first, name.last]
            user = Commonsense::Core::User.find_or_create_by_first_name_and_last_name(first_name, last_name)
            unless user.email
              user.email = payload[:author][:email]
              user.save
            end
            document.user = user
          when "chatmessage"
            find_by_name(document, payload[:sender])
          when "story"
            find_by_name(document, payload[:requested_by])
          when "mail"
            name = payload[:header][:from].split("<").first
            find_by_name(document, name)
          end
        end
      end
      
      def self.find_by_name(document, name)
        name = name.split
        first_name, last_name = [name.first, name.last]
        document.user = Commonsense::Core::User.find_or_create_by_first_name_and_last_name(first_name, last_name)
      end
    end
  end
end

class Commonsense::Core::Document 
  before_save do |document|
    Commonsense::Filters::UserAssociationFilter.filter(document)
  end
end