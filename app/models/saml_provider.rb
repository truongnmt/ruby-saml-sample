class SamlProvider < ApplicationRecord
  include Saml::Provider

  def self.find_by_entity_id(entity_id)
    find_by entity_id: entity_id
  end
end
