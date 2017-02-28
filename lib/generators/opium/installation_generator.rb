require 'rails/generators'
require 'generators/opium/model_generator'

module Opium
  module Generators
    class InstallationGenerator < ::Rails::Generators::Base
      desc "Creates an Opium installation model"

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def run_model_generator
        generate 'model', *['installation', *attributes, '--parent=opium/installation']
      end
    end
  end
end
