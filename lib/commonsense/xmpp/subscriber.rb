require 'rubygems'
require "xmpp4r"
require "xmpp4r/pubsub"
require "xmpp4r/pubsub/helper/servicehelper.rb"
require "xmpp4r/pubsub/helper/nodebrowser.rb"
require "xmpp4r/pubsub/helper/nodehelper.rb"

module Commonsense
  module Xmpp


    class NodeSubscriber

      def self.subscribe
        include Jabber
        Jabber::debug = true
        jid = 'jomis_cinergy@nexus.local'
        password = 'jomis_cinergy'
        node = 'home/nexus.local/cinergy/updates'
        service = 'pubsub.nexus.local'

        # connect XMPP client
        client = Client.new(JID.new(jid))
        # remove "127.0.0.1" if you are not using a local ejabberd
        client.connect("nexus.local")
        client.auth(password)
        client.send(Jabber::Presence.new.set_type(:available))
        sleep(1)
        # subscribe to the node
        pubsub = PubSub::ServiceHelper.new(client, service)
        pubsub.subscribe_to(node)
        subscriptions = pubsub.get_subscriptions_from_all_nodes()
        puts "subscriptions: #{subscriptions}\n\n"
        puts "events:\n"

        # set callback for new events

        pubsub.add_event_callback do |event|
          begin
            event.payload.each do |e|
              puts e,"----\n"
            end
          rescue
            puts "Error : #{$!} \n #{event}"

          end
        end
        # infinite loop
        loop do
          sleep 1
        end

      end
    end
    NodeSubscriber.subscribe
  end
end