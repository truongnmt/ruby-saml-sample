# frozen_string_literal: true

class SamlProvider < ActiveRecord::Base
  include Saml::Provider

  class << self
    def find_by_entity_id(entity_id)
      tenant_saml_setting = where(idp_entity_id: entity_id).or(
          SamlProvider.where(tenant_entity_id: entity_id)).first

      return nil unless tenant_saml_setting

      entity_descriptor = if tenant_saml_setting.idp_entity_id == entity_id
                            build_idp_entity_descriptor(tenant_saml_setting)
                          else
                            build_sp_entity_descriptor(tenant_saml_setting)
                          end
      if entity_descriptor.sp_sso_descriptor.present?
        file = 'server.key'
        Saml::BasicProvider.new(entity_descriptor, nil, 'service_provider', OpenSSL::PKey::RSA.new(::File.read(file)))
      else
        Saml::BasicProvider.new(entity_descriptor, nil, 'identity_provider', nil)
      end
    end

    def build_idp_entity_descriptor(tenant_saml_setting)
      entity_descriptor = Saml::Elements::EntityDescriptor.new
      entity_descriptor.entity_id = tenant_saml_setting.idp_entity_id

      sso_service = Saml::Elements::IDPSSODescriptor::SingleSignOnService.new
      sso_service.binding = 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect'
      sso_service.location = tenant_saml_setting.idp_sso_url

      idp_sso_descriptor = Saml::Elements::IDPSSODescriptor.new
      idp_sso_descriptor.single_sign_on_services << sso_service

      key_descriptor = Saml::Elements::KeyDescriptor.new
      key_descriptor.use = 'signing'
      key_descriptor.certificate = tenant_saml_setting.idp_cert
      idp_sso_descriptor.key_descriptors << key_descriptor

      entity_descriptor.idp_sso_descriptor = idp_sso_descriptor
      entity_descriptor
    end

    def build_sp_entity_descriptor(tenant_saml_setting)
      entity_descriptor = Saml::Elements::EntityDescriptor.new
      entity_descriptor.entity_id = tenant_saml_setting.tenant_entity_id

      sp_sso_descriptor = Saml::Elements::SPSSODescriptor.new
      sp_sso_descriptor.add_assertion_consumer_service('urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
                                                       tenant_saml_setting.tenant_acs_url, 1)

      entity_descriptor.sp_sso_descriptor = sp_sso_descriptor
      entity_descriptor
    end
  end
end

