module Opium
  module Model
    module Dirty
      extend ActiveSupport::Concern
      
      included do
        include ActiveModel::Dirty
        class_eval do
          alias_method_chain :initialize, :dirty
          alias_method_chain :save, :dirty
        end
      end
      
      def initialize_with_dirty( attributes = {} )
        initialize_without_dirty( attributes ).tap { self.send :clear_changes_information }
      end
    
      def save_with_dirty( options = {} )
        save_without_dirty( options ).tap { self.send :changes_applied }
      end
    end
  end
end