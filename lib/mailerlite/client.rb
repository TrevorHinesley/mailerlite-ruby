# frozen_string_literal: true

require 'http'

MAILERLITE_API_URL = 'https://connect.mailerlite.com/api'

# mailerlite-ruby is a gem that integrates all endpoints from MailerLite API
module MailerLite
  class << self
    attr_accessor :api_token

    # Config method to allow passing API token through an initializer
    def configure
      yield self
    end
  end

  class Client
    attr_reader :api_token

    def initialize(api_token = nil)
      # Use passed token or fallback to global config, Rails credentials, or ENV
      @api_token = api_token || MailerLite.api_token || fetch_api_token
    end

    def fetch_api_token
      # Check for Rails credentials if Rails is defined
      if defined?(Rails) && Rails.application.credentials&.mailer_lite&[:api_token]
        Rails.application.credentials.mailer_lite[:api_token]
      else
        # Fall back to ENV variable
        ENV['MAILERLITE_API_TOKEN']
      end
    end

    def headers
      {
        'User-Agent' => "MailerLite-client-ruby/#{MailerLite::VERSION}",
        'Accept' => 'application/json',
        'Content-type' => 'application/json'
      }
    end

    def http
      raise 'API token is missing' unless @api_token

      HTTP
        .timeout(connect: 15, read: 30)
        .auth("Bearer #{@api_token}")
        .headers(headers)
    end
  end
end
