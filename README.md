# ruby-saml-sample

Sample send SAML request and process Response.
Using [libsaml](https://github.com/digidentity/libsaml) gem.

Notice: On IdP make sure to choose "Sign SAML response and assertion".

- In the project repository run `bundle install`
- Download IdP metadata and place in `config/metadata`
- Change sp metadata according to your IdP
- Navigate to 'localhost:3000/saml/sso'
- After login on your IdP, you will be redirect to 'localhost/saml/acs' with claimed information
 