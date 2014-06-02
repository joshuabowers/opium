module Opium
  module Model
    class Field
      def initialize(name, type, default, readonly)
        self.name, self.type, self.default, self.readonly = name, type, default, readonly
      end
      
      attr_reader :name, :type, :readonly
      
      def default
        if @default.respond_to? :call
          @default.call
        else
          @default
        end
      end
      
      private
      
      attr_writer :name, :type, :default, :readonly
    end
  end
end