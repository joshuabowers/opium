module Opium
  module Model
    module Attributable
      extend ActiveSupport::Concern
      
      included do
        include ActiveModel::ForbiddenAttributesProtection
      end
      
      def initialize( attributes = {} )
        super( self.class.default_attributes( self ).merge attributes )
      end
      
      def attributes
        @attributes ||= {}.with_indifferent_access
      end
      
      def attributes=(values)
        sanitize_for_mass_assignment( rubyize_field_names( values ) ).each do |k, v|
          field_info, setter = self.class.fields[k], :"#{k}="
          if field_info.present? || self.respond_to?( setter )
            send( setter, v )
          else
            attributes[k] = v
          end
        end
      end
      
      def attributes_to_parse( options = {} )
        options[:except] ||= self.class.fields.values.select {|f| f.readonly? }.map {|f| f.name} if options[:not_readonly]
        Hash[*self.as_json( options ).flat_map {|k, v| [self.class.fields[k].name_to_parse, self.class.fields[k].type.to_parse(v)]}]
      end
      
      private
      
      def rubyize_field_names( hash )
        hash.transform_keys {|k| self.class.ruby_canonical_field_names[k] || k}
      end
    end
  end
end