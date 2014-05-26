require 'active_support/concern'
require 'active_model'

module Opium
  module Model
    module Naming
      extend ActiveSupport::Concern
      
      included do
        extend ActiveModel::Naming        
      end
    end
  end
end