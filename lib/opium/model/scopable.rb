module Opium
  module Model
    module Scopable
      extend ActiveSupport::Concern
      
      included do
      end
      
      module ClassMethods
        def find( id )
          new self.http_get( id: id )
        end
        
        def scope( scope_name, criteria = nil, &block )
          class_eval do
            method_body = if block_given? || criteria.is_a?(Proc)
              block || criteria
            elsif criteria.nil?
              raise ArgumentError, "Criteria cannot be nil if no block is provided."
            else
              -> { criteria }
            end
            define_singleton_method( scope_name, method_body )
          end
        end
        
        def default_scope( criteria = nil, &block )
          @default_scope = block || criteria if block_given? || criteria.present?
          s = @default_scope || unscoped
          s.is_a?( Proc ) ? s.call : s
        end
        
        def scoped
          
        end
        
        def unscoped
          if block_given?
            scoping { yield }
          else
            blank_criteria
          end
        end
        
        def blank_criteria
          Criteria.new( self.model_name )
        end
        
        def scoping
          if block_given?
            yield
          else
            blank_criteria
          end
        end
      end
    end
  end
end