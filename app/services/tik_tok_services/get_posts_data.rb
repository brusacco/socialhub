# frozen_string_literal: true

module TikTokServices
  class GetProfileData
    include HTTParty

    base_uri 'https://api.tikapi.io/public'

    API_KEY = 'srI2PsFUSz6VPLLcHwr2VqfFDjDTXXUkMv1xt1aJwiwQoZ9g'

    def self.fetch_posts(sec_uid)
      response = get('/posts', { query: { secUid: sec_uid }, headers: { 'X-API-KEY' => API_KEY } })
      response.parsed_response
    end
  end
end
