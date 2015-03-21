module Opium
  class Railtie < Rails::Railtie
    config.app_generators.orm :opium, migration: false
    
    # config.opium = ::Opium::Configuration
    
    initializer 'opium.load-config' do
      config_file = Rails.root.join( 'config', 'opium.yml' )
      if config_file.file?
        # ::Opium.load!( config_file )
      end
    end
  end
end