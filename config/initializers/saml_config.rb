Saml.setup do |config|
  config.register_store :file, Saml::ProviderStores::File.new("config/metadata", "config/ssl/server.key"), default: true
end
