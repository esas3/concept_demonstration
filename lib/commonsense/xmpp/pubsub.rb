require 'rubygems'
require "xmpp4r"
require "xmpp4r/pubsub"
require "xmpp4r/pubsub/helper/servicehelper.rb"
require "xmpp4r/pubsub/helper/nodebrowser.rb"
require "xmpp4r/pubsub/helper/nodehelper.rb"

module Commonsense
  module Xmpp


    class NodeCreater

      def self.create_nodes
        include Jabber
        Jabber::debug = true

        service = 'pubsub.nexus.local'
        jid = 'cinergy@nexus.local/nexus'

        password = 'cinergy'
        client = Client.new(JID.new(jid))
        client.connect
        client.auth(password)

        client.send(Jabber::Presence.new.set_type(:available))
        pubsub = PubSub::ServiceHelper.new(client, service)
        pubsub.create_node('home/nexus.local/cinergy/')
        pubsub.create_node('home/nexus.local/cinergy/updates')
      end
    end
  
    NodeCreater.create_nodes
  
  end
end