require 'rails/generators'

module Opium
  module Generators
    class ConfigGenerator < ::Rails::Generators::Base
      source_root ::File.expand_path( "../templates/", __FILE__ )
      
      desc "Creates an Opium configuration file at config/opium.yml"
      
      def create_config_file
        copy_file 'config.yml', ::File.join( 'config', 'opium.yml' )
      end
    end
  end
end