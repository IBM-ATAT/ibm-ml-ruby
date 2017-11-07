
module IBM
  module ML
    # Class for calling Local Machine Learning scoring service
    class Local
      include ML

      def initialize(host, username, password)
        @host = host
        super(username, password)
        @http.use_ssl     = true
        @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      def score(deployment_id, record)
        url = URI("https://#{@host}/v2/scoring/online/#{deployment_id}")

        # noinspection RubyStringKeysInHashInspection
        header = {
          'authorization' => "Bearer #{fetch_token}",
          'content-type'  => 'application/json'
        }

        request      = Net::HTTP::Post.new(url, header)
        request.body = { fields: record.keys, records: [record.values] }.to_json

        response = @http.request(request)

        begin
          body = JSON.parse(response.read_body)
          body.key?('records') ? body : raise(ScoringError, response.read_body)
        rescue JSON::ParserError
          raise(ScoringError, response.read_body)
        end
      end

      def query_score(score, field)
        query_ml_score(score, field, 'records')
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

    class ScoringError < StandardError
    end
  end
end
