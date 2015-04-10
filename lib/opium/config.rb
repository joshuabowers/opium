module Opium
  extend self
  
  def configure
    yield config
  end

  def config
    @config ||= Opium::Config.new
  end
  
  def load!( path, environment = nil )
    settings = load_yaml( path, environment )
    configure do |config|
      settings.each do |key, value|
        config.send("#{key}=", value)
      end
    end
  end
  
  def reset
    @config = nil
  end
  
  private

  def load_yaml( path, environment = nil )
    env = environment ? environment.to_s : env_name
    YAML.load(ERB.new(::File.new(path).read).result)[env]
  end

  def env_name
    defined?( Rails ) ? Rails.env : ( ENV["RACK_ENV"] || ENV["OPIUM_ENV"] || raise( "Could not determine environment" )  )
  end
    
  class Config
    include ActiveSupport::Configurable
    
    config_accessor( :app_id ) { 'PARSE_APP_ID' }
    config_accessor( :api_key ) { 'PARSE_API_KEY' }
    config_accessor( :master_key ){ 'PARSE_MASTER_KEY' }
    config_accessor( :log_network_responses ) { false }
  end
end