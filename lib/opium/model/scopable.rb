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
        
        def scope( scope_name, criteria )
          class_eval do
            define_singleton_method(scope_name) do
              criteria.is_a?(Proc) ? criteria.call : criteria
            end
          end
        end
        
        def default_scope( criteria = nil )
          @default_scope = criteria if criteria.present?
          @default_scope || Criteria.new
        end
        
        def scoped
          
        end
        
        def unscoped
          
        end
      end
    end
  end
end