class SamlController < ApplicationController
  skip_before_action :verify_authenticity_token

  extend Saml::Rails::ControllerHelper
  current_provider :set_provider

  def request_authentication
    destination = Saml.current_provider.single_sign_on_service_url(Saml::ProtocolBinding::HTTP_POST)
    authn_request = Saml::AuthnRequest.new(
        destination: destination
    )

    session[:authn_request_id] = authn_request._id

    @saml_attributes = Saml::Bindings::HTTPPost.create_form_attributes(authn_request)

    params_prefix = @saml_attributes[:location] =~ /\?/ ? '&' : '?'
    request_params = "#{params_prefix}#{@saml_attributes[:variables].to_query}"
    redirect_to @saml_attributes[:location] + request_params
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
        @response.assertion.fetch_attribute('any_attribute')
        render :receive_response
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
    Saml.provider('https://app.onelogin.com/saml/metadata/fed4e0ba-c59b-4098-adfa-17c20814bb57')
  end
end
