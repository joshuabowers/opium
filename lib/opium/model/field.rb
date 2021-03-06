module Opium
  module Model
    class Field
      def initialize(name, type, default, readonly, as)
        self.name, self.type, self.default, self.readonly, self.as = name, type, default, readonly, as
      end

      attr_reader :name, :type, :readonly, :as

      def default( context = nil )
        if @default.respond_to? :call
          params = []
          params.push( context ) if @default.arity != 0
          @default.call( *params )
        else
          @default
        end
      end

      def contextual_default_value( context = nil)
        type.to_ruby( default( context ) )
      end

      def readonly?
        self.readonly == true
      end

      def relation?
        self.type == Relation
      end

      def virtual?
        relation? || self.type == Reference
      end

      def name_to_parse
        @name_to_parse ||= (self.as || self.name).to_s.camelize(:lower)
      end

      def name_to_ruby
        @name_to_ruby ||= (self.as || self.name).to_s.underscore
      end

      private

      attr_writer :name, :type, :default, :readonly, :as
    end
  end
end
