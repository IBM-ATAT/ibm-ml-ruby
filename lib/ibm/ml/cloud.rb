module IBM
  module ML
    # Class for calling cloud-based Watson Machine Learning scoring service
    class Cloud
      include ML

      def initialize(username, password, instance_id)
        super('ibm-watson-ml.mybluemix.net', username, password)
        @instance_id = instance_id
        @http.use_ssl = true
      end

      def models
        get_request "#{instance_url}/published_models", 'resources'
      end

      def deployments
        get_request "#{instance_url}/deployments", 'resources'
      end

      def deployment(deployment_id)
        find_by_id(deployments, deployment_id)
      end

      def deployment_by_name(name)
        find_by_name(deployments, name)
      end

      def model(model_id)
        get_request "#{instance_url}/published_models/#{model_id}", 'entity'
      end

      def model_by_name(name)
        find_by_name(models, name)
      end

      def score_by_name(name, record)
        deployment = find_by_name(deployments, name)
        score(deployment['metadata']['guid'], record)
      end

      def score(deployment_id, record)
        deployment  = deployment(deployment_id)['entity']
        field_names = model_of_deployment(deployment)['entity']['input_data_schema']['fields'].map do |f|
          f['name']
        end

        cleaned_rec   = record.map { |k, v| [k.downcase, v] }.to_h
        record_values = field_names.map { |name| cleaned_rec[name.downcase] }

        response = post_request deployment['scoring_url'], {
          fields: field_names,
          values: [record_values]
        }.to_json

        raise(response['message'] + ' : ' + response['description']) if response.key?('message')
        response
      end

      def query_score(score, field)
        query_ml_score(score, field, 'values')
      end

      private

      def ldap_url
        "https://#{@host}/v3/identity/token"
      end

      def instance_url
        "https://#{@host}/v3/wml_instances/#{@instance_id}"
      end

      def ldap_request(url)
        request = Net::HTTP::Get.new(url)
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
        raise(QueryError, "Could not find resource with id \"#{guid}\"")
      end

      def find_by_name(response, name)
        response['resources'].each do |resource|
          return resource if resource['entity']['name'] == name
        end
        raise(QueryError, "Could not find resource with name \"#{name}\"")
      end

      def model_of_deployment(deployment)
        model(deployment['published_model']['guid'])
      end
    end

    class AuthError < StandardError
    end
    class QueryError < StandardError
    end
  end
end
