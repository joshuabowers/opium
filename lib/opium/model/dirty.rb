module Opium
  module Model
    module Dirty
      extend ActiveSupport::Concern
      
      included do
        include ActiveModel::Dirty
      end
      
      def initialize( attributes = {} )
        super( attributes ).tap { self.send :clear_changes_information }
      end
      
      def save( options = {} )
        super( options ).tap { self.send :changes_applied }
      end
    end
  end
end