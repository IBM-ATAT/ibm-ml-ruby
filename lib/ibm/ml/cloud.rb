module IBM
  module ML
    # Class for calling cloud-based Watson Machine Learning scoring service
    class Cloud
      include ML

      def initialize(username, password)
        @host = 'ibm-watson-ml.mybluemix.net'
        super
        @http.use_ssl = true
      end

      def published_models
        get_request "https://#{@host}/v2/published_models", 'resources'
      end

      def deployments
        get_request "https://#{@host}/v2/deployments", 'resources'
      end

      def get_model(model_id)
        get_request "https://#{@host}/v2/published_models/#{model_id}", 'entity'
      end

      def get_score(model_id, deployment_id, record)
        url = URI("https://#{@host}/v2/published_models/#{model_id}/deployments/#{deployment_id}/online")

        # noinspection RubyStringKeysInHashInspection
        header = {
          'authorization' => "Bearer #{fetch_token}",
          'content-type'  => 'application/json'
        }

        model_fields = get_model(model_id)['entity']['input_data_schema']['fields']
        request      = Net::HTTP::Post.new(url, header)
        request.body = {
          fields: model_fields.map { |field| field['name'] },
          values: [record.values]
        }.to_json

        response = @http.request(request)

        body = JSON.parse(response.read_body)
        return body if body.key?('fields') && body.key?('values')
        raise(body['message'] + ' : ' + body['description'])
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
