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

      def models
        get_request "https://#{@host}/v2/published_models", 'resources'
      end

      def deployments
        get_request "https://#{@host}/v2/deployments", 'resources'
      end

      def deployment(guid)
        find_by_id(deployments, guid)
      end

      def deployment_by_name(name)
        find_by_name(deployments, name)
      end

      def model(model_id)
        get_request "https://#{@host}/v2/published_models/#{model_id}", 'entity'
      end

      def model_by_name(name)
        find_by_name(models, name)
      end

      def score_by_name(name, record)
        deployment = find_by_name(deployments, name)
        score(deployment['metadata']['guid'], record)
      end

      def score(deployment_id, record)
        deployment = deployment(deployment_id)
        url = URI(deployment['entity']['scoring_href'])

        header = {
          'authorization' => "Bearer #{fetch_token}",
          'content-type'  => 'application/json'
        }

        model_id = deployment['entity']['published_model']['guid']
        model_fields = model(model_id)['entity']['input_data_schema']['fields']
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

      def query_score(score, field)
        fields = score['fields'].map(&:upcase)
        index = fields.index(field.upcase)
        score['values'].map { |record| record[index] }
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

      def find_by_id(response, guid)
        response['resources'].each do |resource|
          return resource if resource['metadata']['guid'] == guid
        end
      end

      def find_by_name(response, name)
        response['resources'].each do |resource|
          return resource if resource['entity']['name'] == name
        end
      end

    end
  end
end
