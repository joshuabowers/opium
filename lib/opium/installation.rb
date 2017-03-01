module Opium
  class Installation
    include Opium::Model

    no_object_prefix!
    no_really_i_need_master!

    def self.inherited( subclass )
      subclass.no_really_i_need_master!
      super
    end

    field :badge, type: Integer
    field :channels, type: Array
    field :time_zone, type: String
    field :device_type, type: Symbol, readonly: true
    field :push_type, type: Symbol, readonly: true
    field :gcm_sender_id, type: Integer
    field :installation_id, type: String, readonly: true
    field :device_token, type: String
    field :channel_uris, type: Array
    field :app_name, type: String
    field :app_version, type: String
    field :parse_version, type: String
    field :app_identifier, type: String
  end
end
