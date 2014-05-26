require 'active_support/concern'

module Opium
  module Model
    module Callbacks
      extend ActiveSupport::Concern
      
      CALLBACKS = %i[before after around].map {|event| %i[save create update destroy validation].map {|action| :"#{event}_#{action}"}}.flatten +
        %i[initialize find touch].map {|action| :"after_#{action}"}
      
      included do
        extend ActiveModel::Callbacks
        
        define_model_callbacks :save
      end
    end
  end
end