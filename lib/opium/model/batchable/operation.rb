module Opium
  module Model
    module Batchable
      class Operation
        def initialize( attributes = {} )
          validate_key_present( attributes, :method )
          validate_key_present( attributes, :path )
          attributes.each do |key, value|
            send( :"#{key}=", value )
          end
        end
        
        attr_reader :method, :path, :body
        
        def to_parse
          {
            method: method.to_s.upcase,
            path: path
          }.tap {|result| result[:body] = body if body }
        end
        
        private
        
        def validate_key_present( attributes, key )
          as_symbol, as_string = key.to_sym, key.to_s
          fail ArgumentError, "missing an operation #{ key } parameter" unless attributes.key?( as_symbol ) || attributes.key?( as_string )
        end
        
        attr_writer :method, :path, :body
      end
    end
  end
end