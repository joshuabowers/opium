module Opium
  module Model
    module Dirty
      extend ActiveSupport::Concern
      
      included do
        include ActiveModel::Dirty
      end
      
      unless self.method_defined? :changes_applied
        def changes_applied
          @previously_changed = changes
          @changed_attributes = ActiveSupport::HashWithIndifferentAccess.new
        end
      end
        
      unless self.method_defined? :reset_changes
        def reset_changes
          @previously_changed = ActiveSupport::HashWithIndifferentAccess.new
          @changed_attributes = ActiveSupport::HashWithIndifferentAccess.new      
        end
      end
    end
  end
end