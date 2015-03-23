module Opium
  module Model
    module Callbacks
      extend ActiveSupport::Concern
      
      CALLBACKS = %w[before after around].map {|event| %w[save create update destroy].map {|action| :"#{event}_#{action}"}}.flatten +
        %w[initialize find touch].map {|action| :"after_#{action}"} +
        %w[before after].map {|event| :"#{event}_validation"}
      
      included do
        extend ActiveModel::Callbacks
        include ActiveModel::Validations::Callbacks
        
        define_model_callbacks :initialize, :find, :touch, only: :after
        define_model_callbacks :save, :create, :update, :destroy
        
        wrap_callbacks_around :save, :destroy, :touch, :find
        wrap_callbacks_around :initialize, :create, :update, private: true
      end
      
      module ClassMethods
        def wrap_callbacks_around( *methods )
          options = methods.last.is_a?(::Hash) ? methods.pop : {}
          methods.each do |method|
            class_eval do
              define_method method do |*args|
                run_callbacks( method ) do
                  super( *args )
                end
              end
              send( :private, method ) if options[:private]
            end
          end
        end
      end
    end
  end
end