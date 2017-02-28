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
      attributes.each {|k, v| self.send( "#{k}=", v )}
    end

    attr_accessor :channels, :where, :data, :push_at, :expires_at, :expiration_interval

    alias_method :criteria, :where
    alias_method :criteria=, :where=

    attr_hash_accessors :data, :alert, :badge, :sound, :content_available, :category, :uri, :title

    def create
      self.class.as_resource(:push) do
        result = self.class.http_post post_data
        result[:result]
      end
    end

    private

    def post_data
      {}.tap do |pd|
        targetize!( pd )
        schedulize!( pd )
        pd[:data] = data
      end
    end

    def targetize!( hash )
      if criteria
        c = criteria
        c = Installation.where( c ) unless c.is_a?( Opium::Model::Criteria )
        c = c.and( channels: channels ) unless channels.empty?
        hash[:where] = c.constraints[:where]
      elsif !channels.empty?
        hash[:channels] = channels
      else
        fail ArgumentError, 'No channels or criteria were specified!'
      end
    end

    def schedulize!( hash )
      fail ArgumentError, 'No scheduled time for #push_at specified!' if expiration_interval && !push_at
      if push_at
        fail ArgumentError, 'Can only schedule a push up to 2 weeks in advance!' if push_at > ( Time.now + ( 2 * 604800 ) )
        fail ArgumentError, 'Cannot schedule pushes in the past... unless you are the Doctor' if push_at < Time.now
        hash[:push_time] = push_at.iso8601
        hash[:expiration_interval] = expiration_interval
      elsif expires_at
        fail ArgumentError, 'Cannot schedule expiration in the past... unless you have a TARDIS' if expires_at < Time.now
        hash[:expiration_time] = expires_at.iso8601
      end
    end
  end
end
