require 'json'
require 'net/https'
require 'ibm/machine_learning/version'

# Module for calling a Machine Learning service
module IBM
  module MachineLearning

    require_relative 'machine_learning/cloud'
    require_relative 'machine_learning/local'
    require_relative 'machine_learning/zos'

    def initialize(username, password)
      @username     = username
      @password     = password
      uri           = URI("https://#{@host}")
      @http         = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = uri.scheme == 'https'
    end

    def fetch_token
      uri          = URI.parse ldap_url
      http         = Net::HTTP.new uri.host, uri.port
      http.use_ssl = uri.scheme == 'https'

      response = http.request ldap_request(http, uri)

      raise response.class.to_s if response.is_a? Net::HTTPClientError
      process_ldap_response(response)
    end

    private

    def get_request(addr, top_key)
      url     = URI(addr)
      header  = { authorization: "Bearer #{fetch_token}" }
      request = Net::HTTP::Get.new url, header

      response = @http.request(request)

      body = JSON.parse(response.read_body)
      body.key?(top_key) ? body : raise(body['message'])
    end
  end
end
