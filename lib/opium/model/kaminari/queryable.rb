if defined?( Kaminari )
  module Opium
    module Model
      module Kaminari
        module Queryable
          extend ActiveSupport::Concern
          
          included do
            include ::Kaminari::PageScopeMethods
          end
        end
      end
      
      Opium::Model::Queryable.send :include, Kaminari::Queryable
    end
  end
end