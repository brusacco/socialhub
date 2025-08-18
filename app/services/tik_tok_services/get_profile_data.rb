# frozen_string_literal: true

require 'httparty'

module TikTokServices
  class GetProfileData < ApplicationService
    include HTTParty

    API_KEY = 'srI2PsFUSz6VPLLcHwr2VqfFDjDTXXUkMv1xt1aJwiwQoZ9g'

    base_uri 'https://api.tikapi.io/public'

    def initialize(username)
      @username = username
    end

    def call
      return handle_error('No username set') unless @username

      response = self.class.get('/check', { query: { username: @username }, headers: { 'X-API-KEY': API_KEY } })
      data = JSON.parse(response.body)
      handle_success(data)
    rescue StandardError => e
      handle_error(e.message)
    end
  end
end
