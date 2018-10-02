require 'rest-client'
require 'json'

module Util
  BASE_URL = 'https://api.routific.com/v1/'

  class << self
    ##
    # method: "GET", "POST"
    # endpoint: "vrp", "vrp-long", "job"
    # token: if nil, raise ArgumentError; if missing "bearer", prefix
    # data: only for POST requests
    #
    def send_request(method, endpoint, token = nil, data = nil)
      url = BASE_URL + endpoint
      headers = {
        content_type: :json,
        accept: :json
      }
      headers['Authorization'] = token if token
      response = nil
      begin
        # Sends HTTP request to Routific API server
        if method == 'GET'
          response = RestClient.get(url, headers)
        elsif method == 'POST'
          response = RestClient.post(url, data.to_json, headers)
        end

        return JSON.parse(response)
      rescue => e
        on_error.call(e, response)
        nil
      end
    end

    def prefix_token(token)
      (/bearer /.match(token).nil?) ? "bearer #{token}" : token
    end

    ##
    # Get/set the error handler.
    #
    # The callback takes 2 positional arguments: (Exception, RestClient::Response)
    #
    # Example of setting the callback:
    #
    # Util.on_error do |ex, res|
    #   puts(ex)
    #   puts(res.body) if res
    # end
    def on_error(&block)
      @on_error = block || @on_error || method(:default_on_error)
    end

    private

    def default_on_error(exception, response)
      puts exception
      return unless response
      error_message = JSON.parse(response.body)
      puts error_message["error"]
    rescue JSON::ParserError
      puts response.body
    end
  end
end
