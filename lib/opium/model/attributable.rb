module Opium
  module Model
    module Attributable
      extend ActiveSupport::Concern
      
      included do
        include ActiveModel::MassAssignmentSecurity
      end
      
      def attributes
        @attributes ||= self.class.default_attributes
      end
      
      def attributes=(values)
        sanitize_for_mass_assignment( rubyize_field_names( values ) ).each do |k, v|
          send( "#{k}=", v )
        end
      end
      
      def attributes_to_parse( options = {} )
        options[:except] ||= self.class.fields.values.select {|f| f.readonly? }.map {|f| f.name} if options[:not_readonly]
        Hash[*self.as_json( options ).map {|k, v| [self.class.fields[k].name_to_parse, v.to_parse]}.flatten]
      end
      
      private
      
      def rubyize_field_names( hash )
        Hash[*hash.map {|k, v| [self.class.ruby_canonical_field_names[k], v]}.flatten]
      end
    end
  end
end