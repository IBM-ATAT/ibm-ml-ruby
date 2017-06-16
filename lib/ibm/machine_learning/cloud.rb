# Class for calling cloud-based Watson Machine Learning scoring service
module IBM
  module MachineLearning
    class Cloud
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

  end
end
