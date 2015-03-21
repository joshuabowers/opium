module Opium
  module Model
    module Dirty
      extend ActiveSupport::Concern
      
      included do
        include ActiveModel::Dirty
        # alias_method_chain :initialize, :dirty
        # alias_method_chain :save, :dirty
      end
      
      # def initialize_with_dirty( attributes = {} )
      #   initialize_without_dirty( attributes )
      #   clear_changes_information
      # end
      #
      # def save_with_dirty( options = {} )
      #   save_without_dirty( options ).tap { changes_applied }
      # end
      
      def initialize( attributes = {} )
        super( attributes ).tap { clear_changes_information }
      end
      
      def save( options = {} )
        super( options ).tap { changes_applied }
      end
      
            
      # def save( options = {} )
      #   (defined?( super ) ? super( options ) : true).tap { changes_applied }
      # end
    end
  end
end