require 'rails/generators/named_base'

module Opium
  module Generators
    class ModelGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path( "../templates/", __FILE__ )
      
      desc "Creates an Opium model"
      
      argument :attributes, type: :array, default: [], banner: "field:type field:type"
      
      check_class_collision
      
      class_option :parent, type: :string, desc: "The parent model for the generated model when using STI"
      
      def create_model_file
        template "model.rb", File.join( "app/models", class_path, "#{file_name}.rb" )
      end
      
      hook_for :test_framework
    end
  end
end