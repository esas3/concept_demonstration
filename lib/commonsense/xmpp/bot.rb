require 'rubygems'
require "xmpp4r"
require "xmpp4r/roster"
require "xmpp4r/pubsub"
require "xmpp4r/pubsub/helper/servicehelper.rb"
require "xmpp4r/pubsub/helper/nodebrowser.rb"
require "xmpp4r/pubsub/helper/nodehelper.rb"


module Commonsense
  module Xmpp


    class Bot

      include Jabber

      def initialize

        @jid = 'jomis_cinergy@nexus.local'
        @password = 'jomis_cinergy'
        Jabber::debug = true
      end

      def connect
        @client = Client.new(JID.new(@jid))
        @client.connect
        @client.auth(@password)

        @roster = Roster::Helper.new(@client)
        #Go online
        @client.send(Presence.new.set_type(:available))
      end

      def run



        #Accept every contact request
        @roster.add_subscription_request_callback do |item,pres|
          @roster.accept_subscription(pres.from)
        end

        #Respond to subscription reply
        # @client.add_update_callback do |presence|
        #         #if presence.from == "john@someserver.com" && presence.ask == :subscribe
        #         if presence.ask == :subscribe
        #           @client.send(presence.from, "Successfully connected to Cinergy")
        #         end
        #       end

        #Respond to received messages
        @client.add_message_callback do |msg_received|
          puts msg_received.body.inspect
          if msg_received.from == "jomis@nexus.local/nexus" then
            msg = Message::new("jomis@nexus.local/nexus","#{msg_received.body}")
            msg.type = :chat
            @client.send(msg)
          end
          if msg_received.from == "inz@nexus.local/nexus" then
            msg = Message::new("inz@nexus.local/nexus","Sorry I am not a qualified Cinergy bot for you")
            msg.type = :chat
            @client.send(msg)
          end

          #show contacts on roster
          # contacts = @roster.find_by_group(nil)
          #         contacts.each {|e| puts e.inspect}
        end

        #Respond to presence changes
        @client.add_presence_callback do |old_presence, new_presence|

        end


      end

      def subscribe
        @node = 'home/nexus.local/cinergy/updates'
        @service = 'pubsub.nexus.local'

        # subscribe Client to topics of interest

        @pubsub = PubSub::ServiceHelper.new(@client, @service)
        @pubsub.subscribe_to(@node)
        #@pubsub.unsubscribe_from(@node,nil)
        @subscriptions = @pubsub.get_subscriptions_from_all_nodes()
        puts "subscriptions: #{@subscriptions}\n\n"
        #@subscriptions.each {|s| @pubsub.unsubscribe_from(@node)}
        puts "events:\n"

        # set callback for new events
        @pubsub.add_event_callback do |event|
          begin
            event.payload.each do |e|
              msg = Message::new("jomis@nexus.local/nexus","#{e.to_s}")
              msg.type = :chat
              @client.send(msg)
              puts e,"----\n"
              sleep(100)
            end
          rescue
            puts "Error : #{$!} \n #{event}"

          end
        end


      end

    end


    bot = Bot.new
    bot.connect
    bot.subscribe
    bot.run
    loop do
      sleep 1
    end
  end
end