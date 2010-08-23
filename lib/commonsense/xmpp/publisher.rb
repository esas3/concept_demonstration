require 'rubygems'
require "xmpp4r"
require "xmpp4r/pubsub"
require "xmpp4r/pubsub/helper/servicehelper.rb"
require "xmpp4r/pubsub/helper/nodebrowser.rb"
require "xmpp4r/pubsub/helper/nodehelper.rb"

module Commonsense
  module Xmpp


    class NodePublisher
      def self.publish
        include Jabber
        Jabber::debug = true
        jid = 'cinergy@nexus.local'

        password = 'cinergy'
        service = 'pubsub.nexus.local'
        node = 'home/nexus.local/cinergy/updates'
        # connect XMPP client
        client = Client.new(JID.new(jid))
        # remove "127.0.0.1" if you are not using a local ejabberd
        client.connect("nexus.local")
        client.auth(password)
        client.send(Jabber::Presence.new.set_type(:available))
        # create item
        pubsub = PubSub::ServiceHelper.new(client, service)
        item = Jabber::PubSub::Item.new
        xml = REXML::Element.new("Cinergy")
        xml.text = 'Updated information available'

        item.add(xml);
        # publish item
        pubsub.publish_item_to(node, item)
      end

    end
    #NodePublisher.publish
  end
end

class Commonsense::Core::Document 
  after_save do |document|
    Commonsense::Xmpp::NodePublisher.publish
  end
  
end