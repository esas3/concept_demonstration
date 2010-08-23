module Commonsense
  class ConfigAttributeNotFoundError < StandardError
    def initialize(attr_name) 
      super("Config attribute not found: #{attr_name}")
    end
  end
  
  module ConfigAttributes
    module ClassMethods
      def set_attribute(attr_name, value)
        @attributes ||= {}
        @attributes[attr_name] = value
      end
      alias_method :[]=, :set_attribute
      # private :set_attribute, :[]=
      
      def attributes(attr_name)
        if @attributes && @attributes.has_key?(attr_name)
          @attributes[attr_name]
        else
          raise ConfigAttributeNotFoundError, attr_name
        end
      end
      alias_method :[], :attributes
      
      def method_missing(name, *args)
        return attributes(name) if args.empty?
        return set_attribute(name, args.first) if args.length == 1
        super(name, *args)
      end
    end
    
    def self.included(base)
      base.extend ClassMethods
    end
  end
  
  class Config
    include ConfigAttributes
  end
  
end