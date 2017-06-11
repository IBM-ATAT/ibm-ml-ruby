require 'json'
require 'net/https'
require 'ibm/machine_learning/version'

module IBM
  # Module for calling a Machine Learning service
  module MachineLearning

    def initialize(username, password)
      @username     = username
      @password     = password
      uri           = URI("https://#{@host}")
      @http         = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = uri.scheme == 'https'
    end

    # Class for calling cloud-based Watson Machine Learning scoring service
    class Watson
      include MachineLearning

      def initialize(username, password)
        @host = 'ibm-watson-ml.mybluemix.net'
        super
        @http.use_ssl = true
      end

      def get_model(deployment_id)
        deployment   = get_request "https://#{@host}/v2/online/deployments/#{deployment_id}", 'entity'
        version_addr = deployment['entity']['artifactVersion']['href']
        model_addr   = version_addr[0..version_addr.index('/versions') - 1]
        get_request model_addr, 'entity'
      end

      def get_deployments
        get_request "https://#{@host}/v2/online/deployments", 'resources'
      end

      def get_score(prefix, deployment_id, record)
        url = URI("https://#{@host}/#{prefix}/v2/scoring/#{deployment_id}")

        header = {
          'authorization' => "Bearer #{fetch_token}",
          'content-type'  => 'application/json'
        }

        request      = Net::HTTP::Put.new(url, header)
        request.body = { record: record }.to_json

        response = @http.request(request)

        body = JSON.parse(response.read_body)
        body.key?('result') ? body['result'] : raise(body['message'])
      end

      private

      def ldap_url
        "https://#{@host}/v2/identity/token"
      end

      def ldap_request(http, url)
        http.use_ssl = true
        request      = Net::HTTP::Get.new url
        request.basic_auth @username, @password
        request
      end

      def process_ldap_response(response)
        JSON.parse(response.read_body)['token']
      end
    end

    class Local
      include MachineLearning

      def initialize(host, username, password)
        @host = host
        super(username, password)
        @http.use_ssl     = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      def get_score(deployment_id, record)
        url = URI("https://#{@host}/#{prefix}/v2/scoring/#{deployment_id}")

        header = {
          'authorization' => "Bearer #{fetch_token}",
          'content-type'  => 'application/json'
        }

        request      = Net::HTTP::Put.new(url, header)
        request.body = { record: record }.to_json

        response = @http.request(request)

        body = JSON.parse(response.read_body)
        body.key?('result') ? body['result'] : raise(body['message'])
      end

      private

      def ldap_url
        "https://#{@host}/v2/identity/token"
      end

      def ldap_request(http, uri)
        http.verify_mode    = OpenSSL::SSL::VERIFY_NONE
        request             = Net::HTTP::Get.new uri
        request['Username'] = @username
        request['Password'] = @password
        request
      end

      def process_ldap_response(response)
        JSON.parse(response.read_body)['accessToken']
      end
    end

    # Class for calling IBM Machine Learning for z/OS scoring service
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
