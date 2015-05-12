module Opium
  module Model
    class Field
      def initialize(name, type, default, readonly, as)
        self.name, self.type, self.default, self.readonly, self.as = name, type, default, readonly, as
      end
      
      attr_reader :name, :type, :readonly, :as
      
      def default
        if @default.respond_to? :call
          @default.call
        else
          @default
        end
      end
      
      def readonly?
        self.readonly == true
      end
      
      def relation?
        self.type == Relation
      end
      
      def name_to_parse
        @name_to_parse ||= (self.as || self.name).to_s.camelize(:lower)
      end
      
      private
      
      attr_writer :name, :type, :default, :readonly, :as
    end
  end
end