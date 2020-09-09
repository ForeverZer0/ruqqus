require_relative 'version'

module Ruqqus

  ##
  # Implements interacting with the Ruqqus API as a user, such as login, posting, account management, etc.
  #noinspection RubyTooManyMethodsInspection
  class Client

    ##
    # The user-agent the client identified itself as.
    USER_AGENT = "ruqqus-ruby/#{Ruqqus::VERSION}".freeze

    ##
    # A collection of valid scopes that can be authorized.
    #
    #   * `:identity` - See your username.
    #   * `:create` - Save posts and comments as you
    #   * `:read` - View Ruqqus as you, including private or restricted content
    #   * `:update` - Edit your posts and comments
    #   * `:delete` - Delete your posts and comments
    #   * `:vote` - Cast votes as you
    #   * `:guildmaster` - Perform Guildmaster actions
    SCOPES = %i(identity create read update delete vote guildmaster).freeze

    ##
    # A set of HTTP headers that will be included with every request.
    DEFAULT_HEADERS = { 'User-Agent': USER_AGENT, 'Accept': 'application/json', 'Content-Type': 'application/json' }.freeze

    ##
    # @!attribute [rw] token
    #   @return [Token] the OAuth2 token that grants the client authentication.

    ##
    # @!attribute [r] identity
    #   @return [User] the authenticated user this client is performing actions as.

    ##
    # @overload initialize(client_id, client_secret, token)
    #   Creates a new instance of the {Client} class with an existing token for authorization.
    #   @param client_id [String] the client ID of your of your application, issued after registration on Ruqqus.
    #   @param client_secret [String] the client secret of your of your application, issued after registration on Ruqqus.
    #   @param token [Token] a valid access token that has previously been granted access for the client.
    #
    # @overload initialize(client_id, client_secret, code)
    #   Creates a new instance of the {Client} class with an existing token for authorization.
    #   @param client_id [String] the client ID of your of your application, issued after registration on Ruqqus.
    #   @param client_secret [String] the client secret of your of your application, issued after registration on Ruqqus.
    #   @param code [String] a the code from the Oauth2 redirect to create a new {Token} and grant access to it.
    def initialize(client_id, client_secret, token)
      @client_id = client_id || raise(ArgumentError, 'client ID cannot be nil')
      @client_secret = client_secret || raise(ArgumentError, 'client secret cannot be nil')

      @token = token.is_a?(Token) ? token : Token.new(client_id, client_secret, token.to_s)
      @token.refresh(client_id, client_secret)
      @session = nil
    end

    attr_reader :token

    def token=(token)
      @token = token || raise(ArgumentError, 'token cannot be nil')
    end

    # @!group Object Querying

    ##
    # Retrieves the {User} with the specified username.
    #
    # @param username [String] the username of the Ruqqus account to retrieve.
    #
    # @return [User] the requested {User}.
    #
    # @raise [ArgumentError] when `username` is `nil` or value does match the {Ruqqus::VALID_USERNAME} regular expression.
    # @raise [Error] thrown when user account does not exist.
    def user(username)
      raise(ArgumentError, 'username cannot be nil') unless username
      raise(ArgumentError, 'invalid username') unless VALID_USERNAME.match?(username)
      User.from_json(http_get("#{Routes::USER}#{username}"))
    end

    ##
    # Retrieves the {Guild} with the specified name.
    #
    # @param guild_name [String] the name of the Ruqqus guild to retrieve.
    #
    # @return [Guild] the requested {Guild}.
    #
    # @raise [ArgumentError] when `guild_name` is `nil` or value does match the {Ruqqus::VALID_GUILD} regular expression.
    # @raise [Error] thrown when guild does not exist.
    def guild(guild_name)
      raise(ArgumentError, 'guild_name cannot be nil') unless guild_name
      raise(ArgumentError, 'invalid guild name') unless VALID_GUILD.match?(guild_name)
      Guild.from_json(http_get("#{Routes::GUILD}#{guild_name}"))
    end

    ##
    # Retrieves the {Post} with the specified name.
    #
    # @param post_id [String] the ID of the post to retrieve.
    #
    # @return [Post] the requested {Post}.
    #
    # @raise [ArgumentError] when `post_id` is `nil` or value does match the {Ruqqus::VALID_POST} regular expression.
    # @raise [Error] thrown when a post with the specified ID does not exist.
    def post(post_id)
      raise(ArgumentError, 'post_id cannot be nil') unless post_id
      raise(ArgumentError, 'invalid post ID') unless VALID_POST.match?(post_id)
      Post.from_json(http_get("#{Routes::POST}#{post_id}"))
    end

    ##
    # Retrieves the {Comment} with the specified name.
    #
    # @param comment_id [String] the ID of the comment to retrieve.
    #
    # @return [Comment] the requested {Comment}.
    #
    # @raise [ArgumentError] when `comment_id` is `nil` or value does match the {Ruqqus::VALID_POST} regular expression.
    # @raise [Error] when a comment with the specified ID does not exist.
    def comment(comment_id)
      raise(ArgumentError, 'comment_id cannot be nil') unless comment_id
      raise(ArgumentError, 'invalid comment ID') unless VALID_POST.match?(comment_id)
      Comment.from_json(http_get("#{Routes::COMMENT}#{comment_id}"))
    end

    # @!endgroup Object Querying

    # @!group Commenting

    ##
    # Submits a new comment on a post.
    #
    # @param body [String] the text content of the post (supports Markdown)
    # @param post [Post,String] a {Post} instance or the unique ID of a post.
    # @param comment [Comment,String] a {Comment} with the post to reply under, or `nil` to reply directly to the post.
    #
    # @return [Comment?] the comment that was submitted, or `nil` if an error occurred.
    #
    # @note This method is restricted to 6/minute, and will fail when that limit is exceeded.
    def comment_create(body, post, comment = nil)
      pid = post.to_s
      parent = comment ? 't3_' + comment.to_s : 't2_' + pid
      comment_submit(parent, pid, body)
    end

    ##
    # Submits a new comment on a post.
    #
    # @param body [String] the text content of the comment (supports Markdown)
    # @param comment [Comment,String] a {Comment} instance or the unique ID of a comment.
    #
    # @return [Comment?] the comment that was submitted, or `nil` if an error occurred.
    #
    # @note This method is restricted to 6/minute, and will fail when that limit is exceeded.
    def comment_reply(body, comment)
      if comment.is_a?(Comment)
        comment_submit(comment.fullname, comment.post_id, body)
      else
        comment = self.comment(comment.to_s)
        comment_submit(comment.fullname, comment.post_id, body)
      end
    end

    ##
    # Deletes an existing comment.
    #
    # @param comment [Comment,String] a {Comment} instance, or the unique ID of the comment to delete.
    #
    # @return [Boolean] `true` if deletion completed without error, otherwise `false`.
    def comment_delete(comment)
      id = comment.is_a?(Comment) ? comment.id : comment.sub(/^t3_/, '')
      url = "#{Routes::API_BASE}/delete/comment/#{id}"
      http_post(url).empty? rescue false
    end

    # @!endgroup Commenting

    # @!group Posting

    ##
    # Creates a new post on Ruqqus as the current user.
    #
    # @param guild [Guild,String] a {Guild} instance or the name of the guild to post to.
    # @param title [String] the title of the post to create.
    # @param body [String?] the text body of the post, which can be `nil` if supplying URL or image upload.
    # @param opts [Hash] The options hash to specify a link or image to upload.
    # @option opts [String] :image (nil) the path to an image file to upload.
    # @option opts [String] :url (nil) a URL to share with the post.
    # @option opts [String] :imgur_client (nil) an Imgur client ID to automatically share images via Imgur instead of
    #   direct upload.
    #
    # @return [Post?] the newly created {Post} instance, or `nil` if an error occurred.
    # @note This method is restricted to 6/minute, and will fail when that limit is exceeded.
    def post_create(guild, title, body = nil, **opts)
      name = guild.is_a?(Guild) ? guild.name : guild.strip.sub(/^\+/, '')
      raise(ArgumentError, 'invalid guild name') unless Ruqqus::VALID_GUILD.match?(name)
      raise(ArgumentError, 'title cannot be nil or empty') unless title && !title.empty?
      params = { title: title, board: name, body: body }

      if opts[:image]
        if opts[:imgur_client]
          params[:url] = Ruqqus.imgur_upload(opts[:imgur_client], opts[:image])
        else
          params[:file] = File.new(opts[:image])
        end
      elsif opts[:url]
        raise(ArgumentError, 'invalid URI') unless URI.regexp =~ opts[:url]
        params[:url] = opts[:url]
      end

      if [params[:body], params[:image], params[:url]].none?
        raise(ArgumentError, 'text body cannot be nil or empty without URL or image') if body.nil? || body.empty?
      end
      Post.from_json(http_post(Routes::SUBMIT, params)) rescue nil
    end

    # @!endgroup Posting

    # @!group Voting

    ##
    # Places a vote on a post.
    #
    # @param post [Post,String] a {Post} instance, or the unique ID of a post.
    # @param value [Integer] the vote value to place, either `-1`, `0`, or `1`.
    #
    # @return [Boolean] `true` if vote was placed successfully, otherwise `false`.
    def vote_post(post, value = 1)
      submit_vote(post.to_s, value, 'https://ruqqus.com/api/v1/vote/post/')
    end

    ##
    # Places a vote on a comment.
    #
    # @param comment [Comment,String] a {Comment} instance, or the unique ID of a comment.
    # @param value [Integer] the vote value to place, either `-1`, `0`, or `1`.
    #
    # @return [Boolean] `true` if vote was placed successfully, otherwise `false`.
    def vote_comment(comment, value = 1)
      submit_vote(comment.to_s, value, 'https://ruqqus.com/api/v1/vote/comment/')
    end

    # @!endgroup Voting

    # @!group Object Enumeration

    ##
    # Enumerates through each post of a user, yielding each to a block.
    #
    # @param user [User,String] a {User} instance or the name of the account to query.
    # @yieldparam post [Post] yields a {Post} to the block.
    # @return [self]
    # @raise [LocalJumpError] when a block is not supplied to the method.
    # @note An API invocation is required for every 25 items that are yielded to the block, so observing brief pauses at
    #   these intervals is an expected behavior.
    def each_user_post(user)
      raise(LocalJumpError, 'block required') unless block_given?
      each_submission(user, Post, 'listing') { |obj| yield obj }
    end

    ##
    # Enumerates through each comment of a user, yielding each to a block.
    #
    # @param user [User,String] a {User} instance or the name of the account to query.
    # @yieldparam comment [Comment] yields a {Comment} to the block.
    # @return [self]
    # @raise [LocalJumpError] when a block is not supplied to the method.
    # @note An API invocation is required for every 25 items that are yielded to the block, so observing brief pauses at
    #   these intervals is an expected behavior.
    def each_user_comment(user)
      raise(LocalJumpError, 'block required') unless block_given?
      each_submission(user, Comment, 'comments') { |obj| yield obj }
    end

    ##
    # Enumerates through each post in the specified guild, and yields each one to a block.
    #
    # @param sort [Symbol] a symbol to determine the sorting method, valid values include `:trending`, `:subs`, `:new`.
    # @yieldparam guild [Guild] yields a {Guild} to the block.
    # @return [self]
    # @raise [LocalJumpError] when a block is not supplied to the method.
    # @note An API invocation is required for every 25 items that are yielded to the block, so observing brief pauses at
    #   these intervals is an expected behavior.
    def each_guild(sort = :subs)
      raise(LocalJumpError, 'block required') unless block_given?

      page = 1
      loop do
        params = { sort: sort, page: page }
        json = http_get(Routes::GUILDS, headers(params: params))
        break if json[:error]
        json[:data].each { |hash| yield Guild.from_json(hash) }
        break if json[:data].size < 25
        page += 1
      end
      self
    end

    ##
    # Enumerates through each post in a guild, yielding each to a block.
    #
    # @param guild [Guild,String] a {Guild} instance, or the name of the guild to query.
    # @param opts [Hash] the options hash.
    # @option opts [Symbol] :sort (:new) Valid: `:new`, `:top`, `:hot`, `:activity`, `:disputed`
    # @option opts [Symbol] :filter (:all) Valid: `:all`, `:day`, `:week`, `:month`, `:year`
    #
    # @yieldparam post [Post] yields a {Post} to the block.
    # @return [self]
    # @raise [LocalJumpError] when a block is not supplied to the method.
    # @note An API invocation is required for every 25 items that are yielded to the block, so observing brief pauses at
    #   these intervals is an expected behavior.
    def each_guild_post(guild, **opts)
      raise(LocalJumpError, 'block required') unless block_given?
      name = guild.to_s
      raise(ArgumentError, 'invalid guild name') unless Ruqqus::VALID_GUILD.match?(name)

      sort = opts[:sort] || :new
      filter = opts[:filter] || :all

      page = 1
      loop do
        params = { page: page, sort: sort, t: filter }
        json = http_get("#{Routes::GUILD}#{name}/listing", headers(params: params))
        break if json[:error]

        json[:data].each { |hash| yield Post.from_json(hash) }
        break if json[:data].size < 25
        page += 1
      end

      self
    end

    ##
    # Enumerates through each comment in a guild, yielding each to a block.
    #
    # @param guild [Guild,String] a {Guild} instance, or the name of the guild to query.
    # @yieldparam [Comment] yields a {Comment} to the block.
    #
    # @return [self]
    # @raise [LocalJumpError] when a block is not supplied to the method.
    def each_guild_comment(guild)
      raise(LocalJumpError, 'block required') unless block_given?
      name = guild.to_s
      raise(ArgumentError, 'invalid guild name') unless Ruqqus::VALID_GUILD.match?(name)

      page = 1
      loop do
        params = { page: page }
        json = http_get("#{Routes::GUILD}#{name}/comments", headers(params: params))
        break if json[:error]

        json[:data].each { |hash| yield Comment.from_json(hash) }
        break if json[:data].size < 25
        page += 1
      end

      self
    end

    ##
    # Enumerates through each comment in a guild, yielding each to a block.
    #
    # @param post [Post,String] a {Post} instance, or the unique ID of the post to query.
    # @yieldparam [Comment] yields a {Comment} to the block.
    #
    # @return [self]
    # @raise [LocalJumpError] when a block is not supplied to the method.
    # @note This method is very inefficient, as it the underlying API does not yet implement it, therefore each comment
    #   in the entire guild must be searched through.
    def each_post_comment(post)
      # TODO: This is extremely inefficient, but will have to do until it gets implemented in the API
      raise(LocalJumpError, 'block required') unless block_given?
      post = self.post(post) unless post.is_a?(Post)
      each_guild_comment(post.guild_name) do |comment|
        next unless comment.post_id == post.id
        yield comment
      end
      self
    end

    ##
    # Enumerates through every post on Ruqqus, yielding each post to a block.
    #
    # @param opts [Hash] the options hash.
    # @option opts [Symbol] :sort (:new) Valid: `:new`, `:top`, `:hot`, `:activity`, `:disputed`
    # @option opts [Symbol] :filter (:all) Valid: `:all`, `:day`, `:week`, `:month`, `:year`
    #
    # @yieldparam post [Post] yields a post to the block.
    # @return [self]
    # @raise [LocalJumpError] when a block is not supplied to the method.
    # @note An API invocation is required for every 25 items that are yielded to the block, so observing brief pauses at
    #   these intervals is an expected behavior.
    def each_post(**opts)
      raise(LocalJumpError, 'block required') unless block_given?

      sort = opts[:sort] || :new
      filter = opts[:filter] || :all

      page = 1
      loop do
        params = { page: page, sort: sort, t: filter }
        json = http_get(Routes::ALL_LISTINGS, headers(params: params))
        break if json[:error]
        json[:data].each { |hash| yield Post.from_json(hash) }
        break if json[:data].size < 25
        page += 1
      end
      self
    end

    ##
    # Enumerates through every post on the "front page", yielding each post to a block.
    #
    # @yieldparam post [Post] yields a {Post} to the block.
    #
    # @return [self]
    # @note The front page uses a unique algorithm that is essentially "hot", but for guilds the user is subscribed to.
    def each_home_post
      raise(LocalJumpError, 'block required') unless block_given?
      page = 1
      loop do
        json = http_get(Routes::FRONT_PAGE, headers(params: { page: page }))
        break if json[:error]
        json[:data].each { |hash| yield Post.from_json(hash) }
        break if json[:data].size < 25
        page += 1
      end
      self
    end

    # @!endgroup Object Enumeration

    ##
    # @return [User] the authenticated user this client is performing actions as.
    def identity
      @me ||= User.from_json(http_get(Routes::IDENTITY))
    end

    ##
    # @overload token_refreshed(&block)
    #   Sets a callback to be invoked when the token is refreshed, and a new access token is assigned.
    #   @yieldparam token [Token] yields the newly refreshed {Token} to the block.
    #
    # @overload token_refreshed
    #   When called without a block, clears any callback that was previously assigned.
    #
    # @return [void]
    def token_refreshed(&block)
      @refreshed = block_given? ? block : nil
    end

    private

    ##
    # @api private
    # Places a vote on a comment or post.
    #
    # @param id [String] the ID of a post or comment.
    # @param value [Integer] the vote to place, between -1 and 1.
    # @param route [String] the endpoint of the vote method to invoke.
    #
    # @return [Boolean] `true` if vote was placed successfully, otherwise `false`.
    def submit_vote(id, value, route)
      raise(Ruqqus::Error, 'invalid ID') unless Ruqqus::VALID_POST.match?(id)
      amount = [-1, [1, value.to_i].min].max
      !!http_post("#{route}#{id}/#{amount}")[:error] rescue false
    end

    ##
    # @api private
    # Retrieves the HTTP headers for API calls.
    #
    # @param opts [Hash] the options hash to include any additional parameters.
    #
    # @return [Hash<Symbol, Sting>] a hash containing the header parameters.
    def headers(**opts)
      hash = DEFAULT_HEADERS.merge({ Authorization: "#{@token.type} #{@token.access_token}" })
      opts[:cookies] = { session: @session } if @session
      hash.merge(opts)
    end

    ##
    # @api private
    # Submits a new comment.
    #
    # @param parent [String] the full name of a post or comment to reply under. (i.e. `t2_`, `t3_`, etc.)
    # @param pid [String] the unique ID of the parent post to comment within.
    # @param body [String] the text body of the comment.
    #
    # @return [Comment] the newly submitted comment.
    def comment_submit(parent, pid, body)
      raise(ArgumentError, 'body cannot be nil or empty') unless body && !body.empty?
      params = { submission: pid, parent_fullname: parent, body: body }
      Comment.from_json(http_post(Routes::COMMENT, params)) rescue nil
    end

    ##
    # @api private
    # Enumerates over each page of posts/comments for a user, and returns the deserialized objects.
    #
    # @param user [User,String] a {User} instance or the name of the account to query.
    # @param klass [Class] the type of object to return, must implement `.from_json`.
    # @param route [String] the final API route for the endpoint, either `"listing"` or "comments"`
    #
    # @return [self]
    def each_submission(user, klass, route)

      username = user.is_a?(User) ? user.username : user.to_s
      raise(Ruqqus::Error, 'invalid username') unless VALID_USERNAME.match?(username)

      page = 1
      loop do
        url = "#{Routes::USER}#{username}/#{route}"
        json = http_get(url, headers(params: { page: page }))
        break if json[:error]

        json[:data].each { |hash| yield klass.from_json(hash) }
        break if json[:data].size < 25
        page += 1
      end
      self
    end

    ##
    # @api private
    # Creates and sends a GET request and returns the response as a JSON hash.
    #
    # @param uri [String] the endpoint to invoke.
    # @param header [Hash] a set of headers to send, or `nil` to use the default headers.
    #
    # @return [Hash] the response deserialized into a JSON hash.
    # @see http_post
    def http_get(uri, header = nil)
      refresh_token
      header ||= headers
      response = RestClient.get(uri.chomp('/'), header)
      @session = response.cookies['session_ruqqus'] if response.cookies['session_ruqqus']
      raise(Ruqqus::Error, 'HTTP request failed') if response.code < 200 || response.code >= 300
      JSON.parse(response, symbolize_names: response.body)
    end

    ##
    # @api private
    # Creates and sends a POST request and returns the response as a JSON hash.
    #
    # @param uri [String] the endpoint to invoke.
    # @param params [Hash] a hash of parameters that will be sent with the request.
    # @param header [Hash] a set of headers to send, or `nil` to use the default headers.
    #
    # @return [Hash] the response deserialized into a JSON hash.
    # @see http_get
    def http_post(uri, params = {}, header = nil)
      refresh_token
      header ||= headers
      response = RestClient.post(uri.chomp('/'), params, header)
      @session = response.cookies['session_ruqqus'] if response.cookies['session_ruqqus']
      raise(Ruqqus::Error, 'HTTP request failed') if response.code < 200 || response.code >= 300
      JSON.parse(response, symbolize_names: response.body)
    end

    ##
    # @api private
    # Checks if token is expired, and refreshes if so, calling the {#token_refreshed} block as if defined.
    def refresh_token
      return unless @token.need_refresh?
      @token.refresh(@client_id, @client_secret)
      @refreshed&.call(@token)
    end
  end
end