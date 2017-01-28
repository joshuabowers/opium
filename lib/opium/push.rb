require 'opium/model/connectable'

module Opium
  class Push
    include Opium::Model::Connectable

    requires_heightened_privileges!

    def initialize( attributes = {} )
      self.channels = []
      self.data = {}.with_indifferent_access
    end

    attr_accessor :channels, :data

    def alert
      data[:alert]
    end

    def alert=( value )
      self.data[:alert] = value
    end

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
