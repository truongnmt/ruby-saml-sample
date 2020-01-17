class CreateSamlProvider < ActiveRecord::Migration[6.0]
  def change
    create_table :saml_providers do |t|
      t.string :entity_id
      t.string :sso_url
      t.string :slo_url
      t.string :idp_cert

      t.timestamps
    end
  end
end
