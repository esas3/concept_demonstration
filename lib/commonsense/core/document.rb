module Commonsense
  module Core
    class Document < ActiveRecord::Base
      has_many :incoming_document_relations, 
                  :class_name => "DocumentRelation", 
                  :foreign_key => "destination_id",
                  :dependent => :destroy
      has_many :outgoing_document_relations, 
                  :class_name => "DocumentRelation", 
                  :foreign_key => "source_id",
                  :dependent => :destroy
      
      has_many :sources, :through => :incoming_document_relations
      has_many :destinations, :through => :outgoing_document_relations
      
      has_many :tag_document_relations, :dependent => :destroy
      has_many :tags, :through => :tag_document_relations
      
      belongs_to :user
      
      has_many :ratings, :as => :rateable, :dependent => :destroy
      
      validates_presence_of :name
      validate :document_payload_type, :if => :document
      
      alias_method :relations, :destinations
      
      attr_accessor :document
      
      def reload_document
        if self.uri =~ /^urn:x-couchdb:/
          uri = self.uri[14..-1]
          prefix = "http://"
          uri = prefix + uri unless uri.start_with?(prefix)
          self.document ||= HashWithIndifferentAccess.new(JSON.parse(RestClient.get(uri).body))
        end
      end
      
      before_save :persist_document_payload, :if => :document
      before_destroy :clean_up_document_store
      
      
      def summary
        reload_document
        @summary ||= case self.document[:type]
        when "mail"
          self.document[:body]
        when "commit", "chatmessage"
          self.document[:message]
        when "story"
          self.document[:description]
        end[0,200]
      end
      
      def doc_type
        reload_document
        @type ||= self.document[:type]
      end
      
      private
      def document_payload_type
        unless self.document && self.document[:type]
          errors.add(:document, "must supply type attribute")
        end
      end
      
      def persist_document_payload
        # FIXME: For now, store all documents on the couch
        self.document[:id] ||= CouchRest::Document.database.server.next_uuid
        doc_id = "#{self.document[:type].titlecase}/#{self.document[:id]}"
        doc = begin
          CouchRest::Document.database.get doc_id
        rescue RestClient::ResourceNotFound
          CouchRest::Document.new "_id" => doc_id
        end
        doc.merge!(self.document)
        success = begin
          doc.save
          self.uri = "urn:x-couchdb:" + doc.uri
        rescue Exception => e
          puts "Error saving document payload for #{doc_id}"
          puts e
          puts e.backtrace
          puts doc.inspect
          false
        end
        success
      end
      
      def clean_up_document_store
        # FIXME: Clean up document store if document payload was stored on
        #        the couch
        if self.uri =~ /^urn:x-couchdb:/
          # For now, assume that documents on the couch are always on the
          # couch defined in Commonsense::Config[:database]
          doc_id = CGI.unescape(self.uri.split("/").last)
          CouchRest::Document.database.get(doc_id).destroy rescue nil
        end
      end
    end
  end
end