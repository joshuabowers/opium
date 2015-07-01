module Opium
  class Schema
    include Opium::Model::Connectable

    requires_heightened_privileges!

    class << self
      def all

      end

      def find( model_name )

      end
    end

    def save

    end

    def delete

    end

    def model
      
    end

    def fields

    end
  end
end
