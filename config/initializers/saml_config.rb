# frozen_string_literal: true

Saml.setup do |config|
  config.register_store :saml_provider, SamlProvider, default: true
end
