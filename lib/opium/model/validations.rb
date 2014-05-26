module Opium
  module Model
    module Validations
      extend ActiveSupport::Concern
      
      include ActiveModel::Validations
    end
  end
end