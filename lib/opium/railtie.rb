module Opium
  class Railtie < Rails::Railtie
    config.app_generators.orm :opium, migration: false
    
    config.opium = ::Opium.config
    
    initializer 'opium.load-config' do
      config_file = Rails.root.join( 'config', 'opium.yml' )
      if config_file.file?
        ::Opium.load!( config_file )
      end
    end
    
    config.to_prepare do
      ::Opium::Model::Criteria.models.clear
    end
  end
end