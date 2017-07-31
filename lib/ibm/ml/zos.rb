module IBM
  module ML
    # Class for calling IBM Machine Learning for z/OS scoring service
    class Zos
      include ML

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

      def ldap_request(_, url)
        request = Net::HTTP::Post.new(url)
        request.set_content_type 'application/json'
        request.body = { username: @username, password: @password }.to_json
        request
      end
    end
  end
end
