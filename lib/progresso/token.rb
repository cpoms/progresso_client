require 'date'

module Progresso
  class Token
    attr_reader :token

    def initialize(json)
      @token = json['access_token']
      @expires = DateTime.strptime(json['.expires'], '%a, %d %b %Y %H:%M:%S %Z')
    end

    def expired?
      @expires < DateTime.now
    end
  end
end
