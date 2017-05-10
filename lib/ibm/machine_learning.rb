require 'json'
require 'ibm/machine_learning/version'

module IBM
  module MachineLearning

    class Watson
      include MachineLearning

      def initialize(username, password)
        @username = username
        @password = password
      end

      private

      def ldap_url
        'https://ibm-watson-ml.mybluemix.net/v2/identity/token'
      end

      def ldap_request(http, url)
        http.use_ssl = true
        request      = Net::HTTP::Get.new url
        request.basic_auth @username, @password
        request
      end

    end

    class Zos
      include MachineLearning

      def initialize(username, password, host, ldap_port, scoring_port)
        @username     = username
        @password     = password
        @host         = host
        @ldap_port    = ldap_port
        @scoring_port = scoring_port
      end

      private

      def ldap_url
        "http://#{@host}:#{@ldap_port}/v2/identity/ldap"
      end

      def ldap_request(http, url)
        request = Net::HTTP::Post.new(url)
        request.set_content_type 'application/json'
        request.body = { username: @username, password: @password }.to_json
        request
      end

    end

    def fetch_token
      url = URI ldap_url

      http = Net::HTTP.new url.host, url.port

      ldap_request(http, url)
      response = http.request ldap_request(http, url)
      raise response.class.to_s if response.is_a? Net::HTTPClientError

      JSON.parse(response.read_body)['token']
    end

  end
end
