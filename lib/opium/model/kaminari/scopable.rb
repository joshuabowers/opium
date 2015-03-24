module Opium
  module Model
    module Kaminari
      module Scopable
        extend ActiveSupport::Concern
        
        included do
          include ::Kaminari::ConfigurationMethods
        end
      end
    end
    
    Opium::Model::Scopable.send :include, Kaminari::Scopable
  end
end