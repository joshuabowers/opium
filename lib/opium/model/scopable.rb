module Opium
  module Model
    module Scopable
      extend ActiveSupport::Concern
      
      included do
      end
      
      module ClassMethods
        def criteria
          @_unscoped ? blank_criteria : default_scope
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
          @default_scope = block || criteria if block_given? || criteria
          s = @default_scope || blank_criteria
          s.is_a?( Proc ) ? unscoped { s.call } : s
        end
        
        def scoped
          
        end
        
        def unscoped
          if block_given?
            @_unscoped = true
            yield
          else
            blank_criteria
          end
        ensure
          @_unscoped = false
        end
        
        def blank_criteria
          Criteria.new( self.model_name )
        end
        
        def with_scope( criteria )
          
        end
      end
    end
  end
end