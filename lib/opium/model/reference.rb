module Opium
  module Model
    class Reference < SimpleDelegator
      class << self
        def to_ruby( value )
          case value
          when Hash
            new( value[:metadata] || value['metadata'], value[:context] || value['context'] )
          when self
            value
          else
            fail ArgumentError, "could not convert #{ value.inspect } into an Opium::Model::Reference"
          end
        end
      end
      
      def initialize( metadata, context )
        self.metadata = metadata
        self.context = context
        fail ArgumentError, 'did not receive a context object!' unless context
        super( nil )
      end
      
      attr_accessor :metadata, :context
      
      def __getobj__
        @reference || __setobj__( lookup_reference )
      end
      
      def __setobj__( obj )
        @reference = obj
      end
      
      def inspect
        if @reference
          @reference.inspect
        else
          "#<#{ self.class.name }<#{ self.metadata.target_class_name }>>"
        end
      end
      
      private
      
      def lookup_reference
        return nil if context.new_record?
        self.metadata.target_class_name.constantize.where( self.metadata.inverse_relation_name => self.context ).first
      end
    end
  end
end