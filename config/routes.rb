Rails.application.routes.draw do
  get "/saml/sso" => "saml#request_authentication"
  post "/saml/acs" => "saml#receive_response"
end
