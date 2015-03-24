if defined?( Kaminari )
  module Opium
    module Model
      module Kaminari
        module Queryable
          extend ActiveSupport::Concern
          
          included do
            include ::Kaminari::PageScopeMethods
            
            alias_method :offset, :skip
            
            delegate :max_per_page, :default_per_page, to: :model_class
            
            define_method ::Kaminari.config.page_method_name do |num|
              limit( default_per_page ).offset( default_per_page * ((num = num.to_i - 1) < 0 ? 0 : num) )
            end
          end
          
          def limit_value
            criteria.constraints[:limit]
          end
          
          def offset_value
            criteria.constraints[:skip]
          end
          
          def model_class
            criteria.model
          end
        end
      end
      
      Opium::Model::Queryable::ClassMethods.send :include, Kaminari::Queryable
      Opium::Model::Criteria.send :include, Kaminari::Queryable
    end
  end
end