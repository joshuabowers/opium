require 'opium/model/connectable'

module Opium
  class Push
    include Opium::Model::Connectable

    class << self
      private

      def attr_hash_accessors( hash_name, *methods )
        methods.each do |method_name|
          attr_hash_accessor( hash_name, method_name )
        end
      end

      def attr_hash_accessor( hash_name, method_name )
        unless respond_to?( method_name )
          define_method method_name do
            self.send( hash_name )[ method_name ]
          end
        end
        setter = "#{ method_name }="
        unless respond_to?( setter )
          define_method setter do |value|
            self.send( hash_name )[ method_name ] = value
          end
        end
      end
    end

    requires_heightened_privileges!

    def initialize( attributes = {} )
      self.channels = []
      self.data = {}.with_indifferent_access
    end

    attr_accessor :channels, :data

    attr_hash_accessors :data, :alert, :badge, :sound, :content_available, :category, :uri, :title

    def create
      fail ArgumentError, 'No channels were specified!' if channels.empty?
      self.class.as_resource(:push) do
        result = self.class.http_post post_data
        result[:result]
      end
    end

    private

    def post_data
      {
        channels: self.channels,
        data: self.data
      }
    end
  end
end
