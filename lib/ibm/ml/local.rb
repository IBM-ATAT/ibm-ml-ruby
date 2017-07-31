
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

      def get_score(deployment_id, hash)
        url = URI("https://#{@host}/v2/scoring/online/#{deployment_id}")

        # noinspection RubyStringKeysInHashInspection
        header = {
          'authorization' => "Bearer #{fetch_token}",
          'content-type'  => 'application/json'
        }

        request      = Net::HTTP::Post.new(url, header)
        request.body = { fields: hash.keys, records: [hash.values] }.to_json

        response = @http.request(request)

        body = JSON.parse(response.read_body)
        body.key?('records') ? body['records'][0] : raise(body['message'])
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
  end
end
