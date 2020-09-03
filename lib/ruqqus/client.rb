require_relative 'version'

module Ruqqus

  ##
  # Implements interacting with the Ruqqus API as a user, such as login, posting, account management, etc.
  #noinspection RubyTooManyMethodsInspection
  class Client

    ##
    # The user-agent the client identified itself as.
    USER_AGENT = "ruqqus-ruby/#{Ruqqus::VERSION} (efreed09@gmail.com)".freeze

    ##
    # A collection of valid scopes that can be authorized.
    SCOPES = %i(identity create read update delete vote guildmaster).freeze

    ##
    # A set of HTTP headers that will be included with every request.
    DEFAULT_HEADERS = { 'User-Agent': USER_AGENT, 'Accept': 'application/json', 'Content-Type': 'application/json' }.freeze

    ##
    # Creates a new instance of the {Client} class.
    #
    # @param token [Token] a valid access token to authorize the client.
    def initialize(token)
      @token = token || raise(ArgumentError, 'token cannot be nil')
      @session = nil
    end

    ##
    # Retrieves the {User} with the specified username.
    #
    # @param username [String] the username of the Ruqqus account to retrieve.
    #
    # @return [User] the requested {User}.
    #
    # @raise [ArgumentError] when `username` is `nil` or value does match the {VALID_USERNAME} regular expression.
    # @raise [Error] thrown when user account does not exist.
    def user(username)
      raise(ArgumentError, 'username cannot be nil') unless username
      raise(ArgumentError, 'invalid username') unless VALID_USERNAME.match?(username)
      User.from_json(http_get("#{Routes::USER_INFO}#{username}"))
    end

    ##
    # Retrieves the {Guild} with the specified name.
    #
    # @param guild_name [String] the name of the Ruqqus guild to retrieve.
    #
    # @return [Guild] the requested {Guild}.
    #
    # @raise [ArgumentError] when `guild_name` is `nil` or value does match the {VALID_GUILD} regular expression.
    # @raise [Error] thrown when guild does not exist.
    def guild(guild_name)
      raise(ArgumentError, 'guild_name cannot be nil') unless guild_name
      raise(ArgumentError, 'invalid guild name') unless VALID_GUILD.match?(guild_name)
      Guild.from_json(http_get("#{Routes::GUILD_INFO}#{guild_name}"))
    end

    ##
    # Retrieves the {Post} with the specified name.
    #
    # @param post_id [String] the ID of the post to retrieve.
    #
    # @return [Post] the requested {Post}.
    #
    # @raise [ArgumentError] when `post_id` is `nil` or value does match the {VALID_POST} regular expression.
    # @raise [Error] thrown when a post with the specified ID does not exist.
    def post(post_id)
      raise(ArgumentError, 'post_id cannot be nil') unless post_id
      raise(ArgumentError, 'invalid post ID') unless VALID_POST.match?(post_id)
      Post.from_json(http_get("#{Routes::POST_INFO}#{post_id}"))
    end

    ##
    # Retrieves the {Comment} with the specified name.
    #
    # @param comment_id [String] the ID of the comment to retrieve.
    #
    # @return [Comment] the requested {Comment}.
    #
    # @raise [ArgumentError] when `comment_id` is `nil` or value does match the {VALID_POST} regular expression.
    # @raise [Error] when a comment with the specified ID does not exist.
    def comment(comment_id)
      raise(ArgumentError, 'comment_id cannot be nil') unless comment_id
      raise(ArgumentError, 'invalid comment ID') unless VALID_POST.match?(comment_id)
      Comment.from_json("#{Routes::COMMENT_INFO}#{comment_id}")
    end

    ##
    # Submits a new comment on a post.
    #
    # @param body [String] the text content of the post (supports Markdown)
    # @param post [Post,String] a {Post} instance or the unique ID of a post.
    # @param comment [Comment,String] a {Comment} with the post to reply under, or `nil` to reply directly to the post.
    #
    # @return [Comment,NilClass] the comment that was submitted, or `nil` if an error occurred.
    #
    # @note This method is restricted to 6/minute, and will fail when that limit is exceeded.
    def comment_create(body, post, comment = nil)

      if post.is_a?(Post)
        pid = post.id
        parent = post.full_name
      else
        pid = post.sub(/^t2_/, '')
        parent = 't3_' + pid
      end

      if comment
        parent = comment.is_a?(Comment) ? comment.full_name : 't3_' + comment.sub(/^t3_/, '')
      end
      comment_submit(parent, pid, body)
    end

    ##
    # Submits a new comment on a post.
    #
    # @param comment [Comment,String] a {Comment} instance or the unique ID of a comment.
    # @param body [String] the text content of the comment (supports Markdown)
    #
    # @return [Comment,NilClass] the comment that was submitted, or `nil` if an error occurred.
    #
    # @note This method is restricted to 6/minute, and will fail when that limit is exceeded.
    def comment_reply(comment, body)
      if comment.is_a?(Comment)
        comment_submit(comment.full_name, comment.post_id, body)
      else
        comment = self.comment(comment.to_s)
        comment_submit(comment.full_name, comment.post_id, body)
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

    ##
    # Creates a new post on Ruqqus as the current user.
    #
    # @param guild [Guild,String] a {Guild} instance or the name of the guild to post to.
    # @param title [String] the title of the post to create.
    # @param body [String,NilClass] the text body of the post, which can be `nil` if supplying URL or image upload.
    # @param opts [Hash] The options hash to specify a link or image to upload.
    #
    #
    # @return [Post,NilClass] the newly created {Post} instance, or `nil` if an error occurred.
    # @note This method is restricted to 6/minute, and will fail when that limit is exceeded.
    def post_create(guild, title, body = nil, **opts)
      name = guild.is_a?(Guild) ? guild.name : guild.strip.sub(/^\+/, '')
      raise(ArgumentError, 'invalid guild name') unless Ruqqus::VALID_GUILD.match?(name)
      raise(ArgumentError, 'title cannot be nil or empty') unless title && !title.empty?
      params = { title: title, board: name }

      if opts[:image]
        #noinspection RubyResolve
        raise(Errno::ENOENT, opts[:image]) unless File.exist?(opts[:image])
        if opts[:imgur_client]
          params[:url] = Ruqqus.imgur_upload(opts[:imgur_client], opts[:image])
          #noinspection RubyYardReturnMatch
          return nil unless params[:url]
        else
          params[:file] = File.new(opts[:image])
        end
      elsif opts[:url]
        raise(ArgumentError, 'invalid URI') unless URI.regexp =~ opts[:url]
        params[:url] = opts[:url]
      end
      params[:body] = body if body

      if [params[:body], params[:image], params[:url]].none?
        raise(ArgumentError, 'text body cannot be nil or empty without URL or image') if body.nil? || body&.empty?
      end
      Post.from_json(http_post("#{Routes::API_BASE}/submit", params)) rescue nil
    end

    ##
    # Deletes an existing post previously created by the current user.
    #
    # @param post [Post,String] a {Post} instance of the unique ID of a post.
    #
    # @return [Boolean] `true` if deletion completed without error, otherwise `false`.
    def post_delete(post)
      id = post.is_a?(Post) ? post.id : post.sub(/^t3_/, '')
      url = "#{Routes::API_BASE}/delete_post/#{id}"
      http_post(url).empty? rescue false
    end

    ##
    # Retrieves the posts of the specified guild.
    #
    # @param guild [Guild,String] a {Guild} instance, or the name of the guild to query.
    #
    # @return [Array<Post>] an array containing the posts within the guild.
    def guild_posts(guild)
      raise(ArgumentError, 'guild cannot be nil') if guild.nil?
      name = guild.is_a?(Guild) ? guild.name : guild.to_s
      raise(Ruqqus::Error, 'invalid guild name') unless Ruqqus::VALID_GUILD.match?(name)

      posts = http_get("#{Routes::API_BASE}/guild/#{name}/listing")
      raise(Ruqqus::Error, "failed to get posts for guild #{name}") if posts[:error]

      posts[:data].map { |hash| Post.from_json(hash) }
    end

    ##
    # @overload each_post(guild, &block)
    #   When called with a block, yields each post of the guild to the block then returns self.
    #   @param guild [Guild,String] a {Guild} instance, or the name of the guild to query.
    #   @yieldparam post [Post] yields a {Post} to the block.
    #   @return [self]
    #
    # @overload each_post(guild)
    #   When called without a block, returns an Enumerator for the posts of the guild.
    #   @param guild [Guild,String] a {Guild} instance, or the name of the guild to query.
    #   @return [Enumerator]
    def each_post(guild)
      #noinspection RubyYardReturnMatch
      return enum_for(__method__, guild) unless block_given?
      guild_posts(guild).each { |post| yield post }
      #noinspection RubyYardReturnMatch
      self
    end

    ##
    # Checks if the specified guild name is valid and available for creation.
    #
    # @param guild_name [String] the name of the guild to query (case insensitive).
    #
    # @return [Boolean] `true` if the specified guild name is valid and available for creation, otherwise `false`.
    def guild_available?(guild_name)
      return false unless VALID_GUILD.match?(guild_name)
      json = http_get("#{Routes::GUILD_AVAILABLE}#{guild_name}")
      !!json[guild_name.to_sym] rescue false
    end

    ##
    # Checks if the specified username is valid and available for creation.
    #
    # @param username [String] the name of the user account to query (case insensitive).
    #
    # @return [Boolean] `true` if the specified username is valid and available for creation, otherwise `false`.
    def username_available?(username)
      return false unless VALID_USERNAME.match?(username)
      json = http_get("#{Routes::USERNAME_AVAILABLE}#{username}")
      !!json[username.to_sym] rescue false
    end

    ##
    # Retrieves an array of {Post} objects associated with a user.
    #
    # @param user [User,String] a {User} instance or the name of the account to query.
    #
    # @return [Array<Post>] the posts submitted by the user.
    # @see each_user_post
    def user_posts(user)
      each_user_submission(user, Post, 'listing').to_a
    end

    ##
    # Retrieves an array of {Comment} objects associated with a user.
    #
    # @param user [User,String] a {User} instance or the name of the account to query.
    #
    # @return [Array<Comment>] the comments submitted by the user.
    # @see each_user_comment
    def user_comments(user)
      each_user_submission(user, Comment, 'comments').to_a
    end

    ##
    # @overload each_user_post(user, &block)
    #   When called with a block, yields each post submitted by the user before returning `self`.
    #   @param user [User,String] a {User} instance or the name of the account to query.
    #   @yieldparam post [Post] yields a {Post} to the block.
    #   @return [self]
    #
    # @overload each_user_post(user, &block)
    #   When called without a block, returns an enumerator for the user's comments.
    #   @param user [User,String] a {User} instance or the name of the account to query.
    #   @return [Enumerator] an enumerator for the user's posts.
    def each_user_post(user)
      #noinspection RubyYardReturnMatch
      return enum_for(__method__, user) unless block_given?
      each_user_submission(user, Post, 'listing') { |obj| yield obj }
      #noinspection RubyYardReturnMatch
      self
    end

    ##
    # @overload each_user_comment(user, &block)
    #   When called with a block, yields each comment submitted by the user before returning `self`.
    #   @param user [User,String] a {User} instance or the name of the account to query.
    #   @yieldparam post [Comment] yields a {Comment} to the block.
    #   @return [self]
    #
    # @overload each_user_comment(user, &block)
    #   When called without a block, returns an enumerator for the user's comments.
    #   @param user [User,String] a {User} instance or the name of the account to query.
    #   @return [Enumerator] an enumerator for the user's comments.
    def each_user_comment(user)
      #noinspection RubyYardReturnMatch
      return enum_for(__method__, user) unless block_given?
      each_user_submission(user, Comment, 'comments') { |obj| yield obj }
      #noinspection RubyYardReturnMatch
      self
    end


    # def identity
    #   http_get("#{Routes::API_BASE}/identity")
    # end

    # def vote_comment(comment, value = 1)
    #   id = comment.is_a?(Comment) ? comment.id : comment.to_s.sub(/^t3_/, '')
    #   raise(Ruqqus::Error, 'invalid comment ID') unless Ruqqus::VALID_POST.match?(id)
    #   amount = [-1, [1, value.to_i].min].max
    #   url = "https://ruqqus.com/api/v1/vote/comment/#{id}/#{amount}"
    #   !!http_post(url)[:error] rescue false
    # end

    private

    ##
    # @api private
    # Checks if the user's access token is stale and needs refreshed.
    # @return [void]
    # @note This is a no-op if it is not yet expired.
    def refresh_token
      @token.refresh if @token && @token.expired?
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
    # @return [self,Enumerator] `self` when called with a block, otherwise an Enumerator object.
    def each_user_submission(user, klass, route)
      #noinspection RubyYardReturnMatch
      return enum_for(__method__, user, klass, route) unless block_given?

      username = user.is_a?(User) ? user.username : user.to_s
      raise(Ruqqus::Error, 'invalid username') unless VALID_USERNAME.match?(username)

      page = 1
      loop do
        url = "#{Routes::API_BASE}/user/#{username}/#{route}"
        json = http_get(url, headers(params: { page: page }))

        break unless json[:data]
        json[:data].each { |hash| yield klass.from_json(hash) }
        break if json[:data].size < 25
        page += 1
      end
      #noinspection RubyYardReturnMatch
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
      response = RestClient.get(uri, header)
      @session = response.cookies['sesssion_ruqqus'] if response.cookies['sesssion_ruqqus']
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
      response = RestClient.post(uri, params, header)
      @session = response.cookies['sesssion_ruqqus'] if response.cookies['sesssion_ruqqus']
      raise(Ruqqus::Error, 'HTTP request failed') if response.code < 200 || response.code >= 300
      JSON.parse(response, symbolize_names: response.body)
    end
  end
end