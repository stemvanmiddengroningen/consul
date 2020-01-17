class WordpressOauth2Service
  require 'json'

  def initialize(code)
    @code = code
  end

  def auth_hash
    parsed_auth_hash.merge(provider: 'wordpress_oauth2')
  end

  private

  def parsed_auth_hash
    access_token = request_access_token
    JSON.parse(HTTParty.get(Rails.application.config.wordpress_oauth_provider_me_endpoint + "?access_token=#{access_token}").body)
  end

  def request_access_token
    response = HTTParty.post(Rails.application.config.wordpress_oauth_provider_token_endpoint,
      :body => {
        grant_type: 'authorization_code',
        code: @code,
        client_id: Rails.application.secrets.wordpress_oauth_provider_key,
        client_secret: Rails.application.secrets.wordpress_oauth_provider_secret,
        redirect_uri:  Rails.application.config.wordpress_oauth_redirect_uri
      }.to_json,
      :headers => {'Content-Type' => 'application/json'}
    )
    response.parsed_response["access_token"]
  end
end
