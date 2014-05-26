module Opium
  module Model
    class Field
      def initialize(name, type, default)
        self.name, self.type, self.default = name, type, default
      end
      
      attr_reader :name, :type
      
      def default
        if @default.respond_to? :call
          @default.call
        else
          @default
        end
      end
      
      private
      
      attr_writer :name, :type, :default
    end
  end
end