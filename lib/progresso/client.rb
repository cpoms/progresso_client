require "excon"
require "json"
require "progresso/token"

module Progresso
  class Client
    def initialize(subdomain, username, password)
      @url = "https://#{subdomain}.progresso.net/v2"
      @username = username
      @password = password
    end

    %w(learners contacts).each do |resource|
      define_method resource do |options = {}|
        response = http_request_with_token("/#{resource}", params: options)

        JSON.parse(response.body)
      end
    end

    private
      def http_request_with_token path, options = {}
        fetch_token if !@token || @token.expired?

        options[:headers] ||= {}
        options[:headers]['Authorization'] = "Bearer #{@token.token}"

        http_request path, options
      end

      def fetch_token
        response = http_request "/Token",
          params: {
            username: @username,
            password: @password,
            grant_type: 'password'
          },
          headers: {
            'Content-Type' => 'application/x-www-form-urlencoded'
          }

        json = JSON.parse(response.body)

        @token = Token.new(json)
      end

      def http_request path, options = {}
        Excon.get(
          "#{@url}#{path}",
          body: URI.encode_www_form(options[:params]),
          headers: options[:headers]
        )
      end
  end
end
