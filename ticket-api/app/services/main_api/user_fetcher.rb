require 'net/http'
require 'uri'
require 'json'

module MainApi
  class UserFetcher
    class Error < StandardError; end
    class NotFound < Error; end
    class ConnectionFailed < Error; end

    def self.call(user_id)
      url = "#{MICROSERVICES::MAIN_SERVICE}/users/#{user_id}"
      uri = URI.parse(url)

      puts "###############\n#{uri}\n###############"

      response = Net::HTTP.get_response(uri)

      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      when Net::HTTPNotFound
        raise NotFound, "User with ID #{user_id} not found"
      else
        raise Error, "Failed to fetch user: #{response.code} #{response.message}"
      end
    rescue SocketError, Errno::ECONNREFUSED, Timeout::Error => e
      raise ConnectionFailed, "Connection error: #{e.message}"
    end
  end
end
