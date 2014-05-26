module Opium
  module Model
    module Serialization
      extend ActiveSupport::Concern
      
      include ActiveModel::Serializers::JSON
    end
  end
end