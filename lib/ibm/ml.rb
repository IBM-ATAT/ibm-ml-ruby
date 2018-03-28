require 'json'
require 'net/https'
require 'ibm/ml/version'

module IBM
  # Module for calling a Machine Learning service
  module ML
    require_relative 'ml/cloud'
    require_relative 'ml/local'
    require_relative 'ml/zos'

    def initialize(host, username, password)
      @host         = host
      @username     = username
      @password     = password
      uri           = URI("https://#{@host}")
      @http         = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = uri.scheme == 'https'
    end

    def fetch_token
      url      = URI(ldap_url)
      request  = ldap_request(url)
      response = @http.request request

      if response.is_a? Net::HTTPClientError
        begin
          body = JSON.parse(response.read_body)
          raise(AuthError, body['errors'][0]['message']) if body.key?('errors')
        rescue JSON::ParserError
          raise response.class.to_s
        end
      end

      process_ldap_response(response)
    end

    def query_ml_score(score, field, values_key)
      fields = score['fields'].map(&:upcase)
      index  = fields.index(field.upcase)
      score[values_key].map { |record| record[index] }[0]
    end

    private

    def get_request(addr, top_key)
      url     = URI(addr)
      header  = auth_header
      request = Net::HTTP::Get.new url, header

      response = @http.request(request)

      body = JSON.parse(response.read_body)
      body.key?(top_key) ? body : raise(body['message'])
    end

    def auth_header
      { 'authorization' => "Bearer #{fetch_token}" }
    end

    def post_request(url, body)
      request      = Net::HTTP::Post.new(url, post_header)
      request.body = body
      response     = @http.request(request)
      JSON.parse(response.read_body)
    end

    def post_header
      header                 = auth_header
      header['content-type'] = 'application/json'
      header
    end
  end
end
