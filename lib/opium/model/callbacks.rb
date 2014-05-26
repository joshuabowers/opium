require 'active_support/concern'

module Opium
  module Model
    module Callbacks
      extend ActiveSupport::Concern
      
      CALLBACKS = %i[before after around].map {|event| %i[save create update destroy].map {|action| :"#{event}_#{action}"}}.flatten +
        %i[initialize find touch].map {|action| :"after_#{action}"} +
        %i[before after].map {|event| :"#{event}_validation"}
      
      included do
        extend ActiveModel::Callbacks
        include ActiveModel::Validations::Callbacks
        
        define_model_callbacks :initialize, :find, :touch, only: :after
        define_model_callbacks :save, :create, :update, :destroy
      end
    end
  end
end