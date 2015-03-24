if defined?( Kaminari )
  module Opium
    module Model
      module Kaminari
        module Queryable
          extend ActiveSupport::Concern
          
          included do
            include ::Kaminari::PageScopeMethods
            
            alias_method :offset, :skip
            
            delegate :max_per_page, :default_per_page, :max_pages, to: :model_class
            
            define_method ::Kaminari.config.page_method_name do |num|
              cache.limit( limit_value ).offset( limit_value * ((num = num.to_i - 1) < 0 ? 0 : num) )
            end
            
            define_method :per do |num|
              super( num ).cache
            end
          end
          
          def limit_value
            criteria.constraints.fetch(:limit, default_per_page)
          end
          
          def offset_value
            criteria.constraints.fetch(:skip, 0)
          end
          
          def model_class
            criteria.model
          end
          
          def entry_name
            model_class.model_name.human.downcase
          end
        end
      end
      
      Opium::Model::Queryable::ClassMethods.send :include, Kaminari::Queryable
      Opium::Model::Criteria.send :include, Kaminari::Queryable
    end
  end
end