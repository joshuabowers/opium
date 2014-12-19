module Opium
  module Model
    module Naming
      extend ActiveSupport::Concern
      
      included do
        extend ActiveModel::Naming
        include ActiveModel::Conversion
      end
    end
  end
end