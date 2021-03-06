module Ruqqus

  ##
  # Represents a Ruqqus [OAuth2](https://oauth.net/2/) access token.
  class Token

    ##
    # The minimum number of seconds that can remain before the token refreshes itself.
    REFRESH_THRESHOLD = 60

    ##
    # @!attribute [r] access_token
    #   @return [String] the access token value.

    ##
    # @!attribute [r] refresh_token
    #   @return [String] the refresh token value.

    ##
    # @!attribute [r] expires
    #   @return [Time] the time the token expires and will require a refresh.

    ##
    # @!attribute [r] type
    #   @return [String] the token type to specify in the HTTP header.

    ##
    # @!attribute [r] scopes
    #   @return [Array<Symbol>] an array of scopes this token authorizes.

    ##
    # Grants access to a user account and returns an a newly created {Token} to use as authentication for it.
    #
    # @param client_id [String] the ID of client application.
    # @param client_secret [String] the secret of the client application.
    # @param code [String] the code received in the redirect response when the user requested API access.
    # @param persist [Boolean] `true` if token will be reusable, otherwise `false`.
    #
    # @return [Token] a newly created {Token} object.
    def initialize(client_id, client_secret, code, persist = true)
      headers = { 'User-Agent': Client::USER_AGENT, 'Accept': 'application/json', 'Content-Type': 'application/json' }
      params = { code: code, client_id: client_id, client_secret: client_secret, grant_type: 'code', permanent: persist }
      resp = RestClient.post('https://ruqqus.com/oauth/grant', params, headers )
      @data = JSON.parse(resp.body, symbolize_names: true)

      raise(Ruqqus::Error, 'failed to grant access for token') if @data[:oauth_error]
    end

    def access_token
      @data[:access_token]
    end

    def refresh_token
      @data[:refresh_token]
    end

    def type
      @data[:token_type]
    end

    def expires
      Time.at(@data[:expires_at])
    end

    def scopes
      @data[:scopes].split(',').map(&:to_sym)
    end

    ##
    # Refreshes the access token and resets its time of expiration.
    #
    # @return [void]
    def refresh(client_id, client_secret)
      headers = { 'User-Agent': Client::USER_AGENT, Authorization: "Bearer #{access_token}" }
      params = { client_id: client_id, client_secret: client_secret, refresh_token: refresh_token, grant_type: 'refresh' }
      resp = RestClient.post('https://ruqqus.com/oauth/grant', params, headers )

      data = JSON.parse(resp.body, symbolize_names: true)
      raise(Ruqqus::Error, 'failed to refresh authentication token') unless resp.code == 200 || data[:oauth_error]
      @data.merge!(data)
      sleep(1) # TODO: Test. Get internment 401 error when token needs refreshed
    end

    ##
    # @return [Boolean] `true` if token is expired, otherwise `false`.
    def expired?
      expires <= Time.now
    end

    ##
    # @return [Boolean] `true` if remaining lifetime is within the {REFRESH_THRESHOLD}, otherwise `false`.
    def need_refresh?
      (expires - Time.now) < REFRESH_THRESHOLD
    end

    ##
    # @return [String] the object as a JSON-formatted string.
    def to_json(*_unused_)
      @data.to_json
    end

    ##
    # Saves this token in JSON format to the specified file.
    #
    # @param filename [String] the path to a file where the token will be written to.
    # @return [Integer] the number of bytes written.
    # @note **Security Alert:** The token is essentially the equivalent to login credentials in regards to security,
    #   so it is important to not share or store it somewhere that it can be easily compromised.
    def save_json(filename)
      File.open(filename, 'wb') { |io| io.write(to_json) }
    end

    ##
    # Loads a token in JSON format from a file.
    #
    # @param filename [String] the path to a file where the token is written to.
    # @return [Token] a newly created {Token} instance.
    def self.load_json(filename)
      from_json(File.read(filename))
    end

    ##
    # Loads the object from a JSON-formatted string.
    #
    # @param json [String,Hash] a JSON string representing the object, or the parsed Hash of the JSON (symbol keys).
    #
    # @return [Object] the loaded object.
    def self.from_json(payload)
      data = payload.is_a?(Hash) ? payload: JSON.parse(payload, symbolize_names: true)
      token = allocate
      token.instance_variable_set(:@data, data)
      token
    end
  end
end