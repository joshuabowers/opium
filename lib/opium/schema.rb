module Opium
  class Schema
    include Opium::Model::Connectable

    requires_heightened_privileges!
    no_really_i_need_master!
    no_object_prefix!

    class << self
      def all
        http_get[:results].map {|schema| new( schema ) }
      end

      def find( model_name, options = {} )
        result = http_get( options.merge id: model_name )
        options[:sent_headers] ? result : new( result )
      end

      def model_name
        @model_name ||= ActiveModel::Name.new( self, nil, self.name )
      end
    end

    attr_reader :class_name, :fields

    def initialize( attributes = {} )
      attributes.with_indifferent_access.tap do |a|
        @class_name = a[:className]
        @fields = ( a[:fields] || {} ).map do |field_name, options|
          Opium::Model::Field.new( field_name, options[:type], nil, false, nil )
        end.index_by(&:name)
      end
    end

    def save

    end

    def delete

    end

    def model

    end
  end
end
