require 'active_support/concern'

module Opium
  module Model
    module Callbacks
      extend ActiveSupport::Concern
    
      included do
      end

      extend ActiveModel::Callbacks
    end
  end
end