class SamlController < ApplicationController
  skip_before_action :verify_authenticity_token

  extend ::Saml::Rails::ControllerHelper
  current_provider :set_provider

  def request_authentication
    destination = Saml.current_provider.single_sign_on_service_url(Saml::ProtocolBinding::HTTP_REDIRECT)
    authn_request = Saml::AuthnRequest.new(
      destination: destination
    )

    session[:authn_request_id] = authn_request._id
    redirect_to Saml::Bindings::HTTPRedirect.create_url(authn_request)
  end

  def receive_response
    if params["SAMLart"]
      # provider should be of type Saml::Provider
      @response = Saml::Bindings::HTTPArtifact.resolve(request, provider.artifact_resolution_service_url)
    elsif params["SAMLResponse"]
      @response = Saml::Bindings::HTTPPost.receive_message(request, :response)
    else
      # handle invalid request
    end

    if @response && @response.success?
      if session[:authn_request_id] == @response.in_response_to
        @attrs = @response.assertion.attribute_statements.flat_map(&:attributes)
        render 'saml/receive_response'
      else
        # handle unrecognized response
      end
      reset_session # It's good practice to reset sessions after authenticating to mitigate session fixation attacks
    else
      # handle failure
    end
  end

  private

  def set_provider
    Saml.provider('http://localhost:3000/saml/metadata')
  end
end
