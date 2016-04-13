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

      def save!( *args )
        super( *args ).tap { self.send :changes_applied }
      end

      private

      unless defined?(clear_changes_information)
        def clear_changes_information
          @previously_changed = ActiveSupport::HashWithIndifferentAccess.new
          @changed_attributes = ActiveSupport::HashWithIndifferentAccess.new
        end
      end

      unless defined?(changes_applied)
        def changes_applied
          @previously_changed = changes
          @changed_attributes = ActiveSupport::HashWithIndifferentAccess.new
        end
      end
    end
  end
end
