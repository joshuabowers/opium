require 'rails/generators'
require 'generators/opium/model_generator'

module Opium
  module Generators
    class UserGenerator < ::Rails::Generators::Base
      desc "Creates an Opium user model"
      
      argument :attributes, type: :array, default: [], banner: "field:type field:type"
      
      check_class_collision
      
      def run_model_generator
        generate 'model', *['user', *attributes, '--parent=opium/user']
      end
    end
  end
end